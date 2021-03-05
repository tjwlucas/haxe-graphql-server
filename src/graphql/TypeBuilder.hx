package graphql;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import graphql.GraphQLField;
import haxe.macro.Type;

using StringTools;
using graphql.TypeBuilder;

class TypeBuilder {
	static var metadata = {
		build: 'graphql',
		built: 'graphql_built',
		hide_field: 'GraphQLHide',
		deprecated: 'deprecationReason'
	}

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

	static function fieldHasMeta(field : Field, name : String) {
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

	static function fieldGetMeta(field: Field, name : String) {
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
				type: graphql.GraphQLTypes.$type,
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
		if(field.fieldHasMeta(metadata.hide_field)) {
			return false;
		}
		return field.access.contains(APublic);
	}

	/**
		Returns a string expression for the deprecation reason, if provided using the @:deprecated metadata
	**/
	static function getDeprecationReason(field:Field):ExprOf<String> {
		var deprecationReason = macro null;
		if(field.fieldHasMeta(metadata.deprecated)) {
			deprecationReason = field.fieldGetMeta(metadata.deprecated).params[0];
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
		var type:String;
		switch (field.kind) {
			case(FVar(TPath({name: a}))):
				type = a;
			default:
				type = 'Unknown';
		}

		if( Reflect.field(GraphQLTypes, type) == null ) {
			throw new Error('Type declaration ($type) not supported', field.pos); 
		}

		return type;
	}
	#end
}
