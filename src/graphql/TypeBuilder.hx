package graphql;

import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;
import graphql.GraphQLField;

using StringTools;
using graphql.TypeBuilder;
using haxe.macro.TypeTools;

enum abstract FieldMetadata(String) from String to String {
	var Hide = "GraphQLHide";
	var Deprecated = "deprecationReason";
	var TypeName = "typeName";
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

		var cls = Context.getLocalClass().get();

		var type_name : ExprOf<String> = cls.classHasMeta(TypeName) ? cls.classGetMeta(TypeName).params[0] : macro $v{cls.name};

		var tmp_class = macro class {
			/**
				Auto-generated list of public fields on the class. Prototype for generating a full graphql definition
			**/
			public static var gql : graphql.TypeObjectDefinition = {
				 fields: $a{graphql_field_definitions},
				 type_name: $type_name
			 };
		}

		for (field in tmp_class.fields) {
			fields.push(field);
		}
	}

	static function classHasMeta(cls : ClassType, name : FieldMetadata) {
		var found = false;
		for (meta in cls.meta.get()) {
			if ([':$name', name].contains(meta.name)) {
				if(found == true) {
					throw new Error('Duplicate metadata found for $name on ${cls.name}', meta.pos);
				}
				found = true;
			}
		}
		return found;
	}

	static function classGetMeta(cls: ClassType, name : FieldMetadata) {
		return cls.meta.get().filter((meta) -> {
			return [':$name', name].contains(meta.name);
		})[0];
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

			var field = new FieldTypeBuilder(f);
			var type = field.getType();

			var field:ExprOf<GraphQLField> = macro {
				name: $v{f.name},
				type: $type,
				description: $v{comment},
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
		/** Always exclude constructors **/
		if(field.name == 'new') {
			return false;
		}
		if(field.fieldHasMeta(Hide)) {
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
	#end
}
