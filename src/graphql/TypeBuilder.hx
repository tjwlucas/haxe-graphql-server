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

	static function buildFieldType(f:Field):ExprOf<GraphQLField> {
		var field = new FieldTypeBuilder(f);
		if (field.isVisible()) {
			var type = field.getType();
			var comment = field.getComment();
			var deprecationReason = field.getDeprecationReason();

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
	#end
}
