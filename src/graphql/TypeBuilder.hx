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
	var Validate = "validate";
	var ValidateAfter = "validateResult";
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
			public static var _gql : graphql.TypeObjectDefinition = {
				 fields: $a{graphql_field_definitions},
				 type_name: $type_name
			 };

			 public var gql : graphql.TypeObjectDefinition = _gql;
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
			var validations = field.getValidators();
			var postValidations = field.getValidators(ValidateAfter);

			var resolve = macro {};
			if(!field.is_function) {
				resolve = macro null;
			} else {
				var joined_arguments = [for(f in field.arg_names) macro args[$v{f}] ];
				var arg_var_defs = [for(f in field.arg_names) macro var $f = args[$v{f}] ];
				validations = arg_var_defs.concat(validations);
				postValidations = arg_var_defs.concat(postValidations);
				var name = f.name;
				resolve = macro (obj, args : php.NativeArray, ctx) -> {
					$b{validations};
					var result = php.Syntax.code('{0}(...{1})', obj.$name, $a{ joined_arguments });
					$b{postValidations};
					return result;

				}
			}


			var field:ExprOf<GraphQLField> = macro {
				name: $v{f.name},
				type: $type,
				description: $v{comment},
				deprecationReason: $deprecationReason,
				args: php.Lib.toPhpArray( ${ field.args } ),
				resolve: $resolve
			}
			return field;
		}
		return null;
	}
	#end
}
