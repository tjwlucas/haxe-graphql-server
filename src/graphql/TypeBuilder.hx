package graphql;

import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;
import graphql.GraphQLField;
import graphql.macro.Util;

using StringTools;
using graphql.TypeBuilder;
using haxe.macro.TypeTools;

class TypeBuilder {
	/**
		Automatically build the GraphQL type definition based on the class
	**/
	macro static public function build():Array<Field> {
		var fields = Context.getBuildFields();
		buildClass(fields);
		return fields;
	}

	#if macro
	static function buildClass(fields:Array<Field>) {
		var graphql_field_definitions:Array<ExprOf<GraphQLField>> = [];
		var graphql_mutation_field_definitions:Array<ExprOf<GraphQLField>> = [];

		var cls = Context.getLocalClass().get();
		Util.debug('Building ${cls.name} object');
		for (f in fields) {
			var new_field = buildFieldType(f);
			if (new_field != null) {
				Util.debug('Adding ${cls.name}.${f.name} query field');
				graphql_field_definitions.push(new_field);
			}
			var new_field = buildFieldType(f, Mutation);
			if (new_field != null) {
				Util.debug('Adding ${cls.name}.${f.name} mutation field');
				graphql_mutation_field_definitions.push(new_field);
			}
		}
		
		var type_name : ExprOf<String> = cls.classHasMeta(TypeName) ? cls.classGetMeta(TypeName).params[0] : macro $v{cls.name};
		var mutation_name : ExprOf<String> = cls.classHasMeta(MutationTypeName) ? cls.classGetMeta(MutationTypeName).params[0] : macro $v{cls.name + "Mutation"};

		var tmp_class = macro class {
			/**
				Auto-generated list of public fields on the class. Prototype for generating a full graphql definition
			**/
			public static var _gql : graphql.TypeObjectDefinition = {
				 fields: $a{graphql_field_definitions},
				 mutation_fields: $a{graphql_mutation_field_definitions},
				 type_name: $type_name,
				 mutation_name: $mutation_name,
				 description: $v{ cls.doc != null ? cls.doc.trim() : null  }
			};

			override public function get_gql() : graphql.TypeObjectDefinition {
				return _gql;
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


	/**
		Retrieves list of metadata with the given name (with or without preceding `:`)
	**/
	static function classGetMetas(cls : ClassType, name : FieldMetadata) {
		return cls.meta.get().filter((meta) -> {
			return [':$name', name].contains(meta.name);
		});
	}

	/**
		Retrieves the *first* metadata item with the provided name (with or without preceding `:`)
	**/
	static function classGetMeta(cls: ClassType, name : FieldMetadata) {
		return classGetMetas(cls, name)[0];
	}

	static function buildFieldType(f:Field, type: GraphQLObjectType = Query):ExprOf<GraphQLField> {
		var cls = Context.getLocalClass().get();
		var field = new FieldTypeBuilder(f, type);

		if (field.isVisible()) {

			var classValidationContext : Array<Expr> = [];
			if (classHasMeta(cls, ClassValidationContext)) {
				var validations = classGetMetas(cls, ClassValidationContext);
				for(v in validations) {
					var expr = v.params[0];
					classValidationContext.push(expr);
				}
			}

			var type = field.getType();
			var comment = field.getComment();
			var deprecationReason = field.getDeprecationReason();
			var validations = field.getValidators();
			var postValidations = field.getValidators(ValidateAfter);
			var validationContext = field.getValidationContext();
			var ctx_var_name = field.getContextVariableName();

			var number_of_validations = validations.length;
			var number_of_post_validations = postValidations.length;

			var arg_var_defs = [for(f in field.arg_names) f == ctx_var_name ? macro var $f = $i{ctx_var_name} : macro var $f = args.$f ];
			validations = classValidationContext.concat(arg_var_defs).concat(validationContext).concat(validations);
			var objectType = TPath({name: cls.name, params: [], pack: cls.pack});
			var name = f.name;

			var fieldPathString = switch(field.isStatic()) {
				case true: '${cls.name}.$name';
				case false: 'obj.$name';
			}
			var fieldPath = Context.parse(fieldPathString, Context.currentPos());
			
			var args_string = field.arg_names.join(', ');

			var getResult = switch(field.is_function) {
				case true: {
					switch field.arg_names.length {
						case 0: macro $fieldPath();
						case _: Context.parse('$fieldPathString($args_string);', Context.currentPos());
					}
				}
				case false: macro $fieldPath;
			}

			var functionBody = validations.concat([
				macro var result = $getResult
			]).concat(postValidations).concat([
				macro return result
			]);

			var resolve = macro {};
			if(
				number_of_validations == 0 
				&& number_of_post_validations == 0 
				&& !field.isStatic() 
				&& !field.is_function
				&& !Context.defined("gql_explicit_resolvers")
			) {
				// Prevents creation of redundant anonymous function that simply returns the property value
				// (This is already the behaviour of the server when no/null callback is provided)
				resolve = macro null;
			} else {
				resolve = macro (obj : $objectType, args : graphql.ArgumentAccessor, $ctx_var_name) -> {
					$b{ functionBody }
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
