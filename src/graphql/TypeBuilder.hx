package graphql;

import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import graphql.GraphQLField;

using StringTools;
using graphql.TypeBuilder;

enum abstract FieldMetadata(String) from String to String {
	var HideField = "GraphQLHide";
	var Deprecated = "deprecationReason";
}

class TypeBuilder {
	macro static public function build():Array<Field> {
		var fields = Context.getBuildFields();
		buildClass(fields);
		return fields;
	}

	#if macro
	static function buildClass(fields:Array<Field>) {
		var graphql_field_definitions:Array<ExprOf<GraphQLField>> = [];
		for (f in fields) {
			var new_field = buildFieldType(f);
			if (new_field != null) {
				graphql_field_definitions.push(new_field);
			}
		}

		var tmp_class = macro class {
			/**
				Auto-generated list of public fields on the class. Prototype for generating a full graphql definition
			**/
			public static var gql_fields:Array<graphql.GraphQLField> = $a{graphql_field_definitions};
		}

		for (field in tmp_class.fields) {
			fields.push(field);
		}
	}

	static function fieldHasMeta(field : Field, name : FieldMetadata) {
		var found = false;
		for (meta in field.meta) {
			if ([':$name', name].contains(meta.name)) {
				if(found == true) {
					throw new Error('Duplicate metadata found for $name on ${field.name}', meta.pos);
				}
				found = true;
			}
		}
		return found;
	}

	static function fieldGetMeta(field: Field, name : FieldMetadata) {
		return field.meta.filter((meta) -> {
			return [':$name', name].contains(meta.name);
		})[0];
	}

	static function buildFieldType(f:Field):ExprOf<GraphQLField> {
		if (isVisible(f)) {
			var deprecationReason = getDeprecationReason(f);
			var comment = getComment(f);
			var type = getType(f);

			var field:ExprOf<GraphQLField> = macro {
				name: $v{f.name},
				type: $type,
				comment: $v{comment},
				deprecationReason: $deprecationReason
			}
			return field;
		}
		return null;
	}

	/**
		Determines if the field should be visible in the GraphQL Schema
	**/
	static function isVisible(field:Field) {
		if(field.fieldHasMeta(HideField)) {
			return false;
		}
		return field.access.contains(APublic);
	}

	/**
		Returns a string expression for the deprecation reason, if provided using the @:deprecated metadata
	**/
	static function getDeprecationReason(field:Field):ExprOf<String> {
		var deprecationReason = macro null;
		if(field.fieldHasMeta(Deprecated)) {
			deprecationReason = field.fieldGetMeta(Deprecated).params[0];
		}
		return deprecationReason;
	}

	/**
		Get the commment string from a field
	**/
	static function getComment(field:Field):Null<String> {
		return if (field.doc != null) {
			field.doc.trim();
		} else {
			null;
		};
	}

	/**
		Determine the type of a field in a macro
	**/
	static function getType(field:Field) {

		var types_class = Context.getType('graphql.GraphQLTypes');
		var static_field_name_list = TypeTools.getClass(types_class).statics.get().map((field) -> return field.name);

		function checkTypeDefined(type) {
			if( !static_field_name_list.contains(type) ) {
				throw new Error('Type declaration ($type) not supported in the GraphQL type builder', field.pos); 
			}
		}

		function arrayType(params: Array<TypeParam>) {
			var type : Expr;
			switch(params[0]) {
				case(TPType(TPath({name: a, params: p}))):
					checkTypeDefined(a);
					if(a == 'Array') {
						var arrayOf = arrayType(p);
						type = macro graphql.GraphQLTypes.$a($arrayOf);
					} else {
						type = macro graphql.GraphQLTypes.$a;
					}
				default:
					checkTypeDefined('Unknown');
			}
			return type;
		}

		var type:Expr;

		switch (field.kind) {
			case(FVar(TPath({name: a, params: p}))):
				checkTypeDefined(a);
				if(a == 'Array') {
					var arrayOf = arrayType(p);
					type = macro graphql.GraphQLTypes.$a($arrayOf);
				} else {
					type = macro graphql.GraphQLTypes.$a;
				}
			default:
				checkTypeDefined('Unknown');
				type = macro 'Unknown';
		}

		return type;
	}
	#end
}
