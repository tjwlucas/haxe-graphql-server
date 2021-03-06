package graphql;

import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;
using graphql.macro.Util;
using StringTools;
using graphql.TypeBuilder;
using haxe.macro.TypeTools;

/**
    Main macro class which autobuilds the `GraphQLObject`s 
**/
class TypeBuilder {
    /**
        Automatically build the GraphQL type definition based on the class
    **/
    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();
        var resultantFields = buildClass(fields);
        return resultantFields;
    }

    #if macro
    /**
        This is the main function which builds a class implementing `GraphQLObject` into a valid GraphQL class

        @param fields An array of the fields on the class to be built
    **/
    static function buildClass(fields:Array<Field>) {
        var graphql_field_definitions:Array<ExprOf<GraphQLField>> = [];
        var graphql_mutation_field_definitions:Array<ExprOf<GraphQLField>> = [];

        var cls = Context.getLocalClass().get();
        var resultantFields = fields.copy();
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
            var fieldBuilder = new FieldTypeBuilder(f);
            if (fieldBuilder.isMagicDeferred() && fieldBuilder.getFunctionBody() == null) {
                resultantFields.remove(f);
            }
        }

        var type_name : ExprOf<String> = cls.classHasMeta(TypeName) ? cls.classGetMeta(TypeName).params[0] : macro $v{cls.name};
        var mutation_name : ExprOf<String>
        = cls.classHasMeta(MutationTypeName) ? cls.classGetMeta(MutationTypeName).params[0] : macro $v{cls.name + "Mutation"};

        var classDoc : ExprOf<String> = switch [cls.classHasMeta(DocMeta), cls.classGetMeta(DocMeta), cls.doc] {
            case [true, meta, _] if (meta.params.length == 0): macro null;
            case [true, meta, _]: meta.params[0];
            case [false, _, null]: macro null;
            case [false, _, _]: macro $v{ cls.doc.trim() };
        }

        var hasMutationFields = (graphql_mutation_field_definitions.length > 0);

        var tmp_class = macro class {
            /**
                Auto-generated list of public fields on the class. Prototype for generating a full graphql definition
            **/
            public static var _gql : graphql.TypeObjectDefinition = {
                fields: () -> $a{graphql_field_definitions},
                mutationFields: () -> $a{graphql_mutation_field_definitions},
                typeName: $type_name,
                mutationName: $mutation_name,
                description: $classDoc,
                hasMutation: $v{ hasMutationFields }
            };

            public var gql(get, null) : graphql.TypeObjectDefinition = null;
            function get_gql() : graphql.TypeObjectDefinition {
                return _gql;
            };
        }

        tmp_class.addFieldsFromClass(resultantFields);
        return resultantFields;
    }

    static function classHasMeta(cls : ClassType, name : FieldMetadata) {
        var found = false;
        for (meta in cls.meta.get()) {
            var nameMatches = [':$name', name].contains(meta.name);
            found = switch [nameMatches, found] {
                case [true, true]: throw new Error('Duplicate metadata found for $name on ${cls.name}', meta.pos);
                case [true, false]: true;
                case [false, _]: found;
            }
        }
        return found;
    }

    /**
        Retrieves list of metadata with the given name (with or without preceding `:`)
    **/
    static function classGetMetas(cls : ClassType, name : FieldMetadata) {
        return cls.meta.get().filterMetas(name);
    }

    /**
        Retrieves the *first* metadata item with the provided name (with or without preceding `:`)
    **/
    static function classGetMeta(cls: ClassType, name : FieldMetadata) {
        return classGetMetas(cls, name)[0];
    }

    static function buildValidations(field : FieldTypeBuilder, cls : ClassType) {
        var classValidationContext : Array<Expr> = [];
        if (classHasMeta(cls, ClassValidationContext)) {
            var validations = classGetMetas(cls, ClassValidationContext);
            for (v in validations) {
                var expr = v.params[0];
                classValidationContext.push(expr);
            }
        }

        var validations = field.getValidators();
        var validationContext = field.getValidationContext();
        var argumentVariableDefinitions = field.getArgumentVariableDefinitions();

        validations = argumentVariableDefinitions.concat(classValidationContext).concat(validationContext).concat(validations);
        return validations;
    }

    @SuppressWarnings("checkstyle:ReturnCount") // The return count check picks up returns inside macro expressions and callbacks
    static function buildFieldType(f:Field, type: GraphQLObjectType = Query):ExprOf<GraphQLField> {
        var cls = Context.getLocalClass().get();
        var field = new FieldTypeBuilder(f, type);

        if (field.isVisible()) {
            var validations = buildValidations(field, cls);
            var postValidations = field.getValidators(ValidateAfter);
            var validationsCount = field.getValidators().length;
            var postValidationsCount = postValidations.length;

            var objectType = TPath({name: cls.name, params: [], pack: cls.pack});
            var name = f.name;

            var fieldPathString = switch (field.isStatic()) {
                case true: '${cls.name}.$name';
                case false: 'obj.$name';
            }
            var fieldPath = Context.parse(fieldPathString, Context.currentPos());

            var args_string = field.argNames.join(", ");

            var getResult = switch (field.isFunction) {
                case true: Context.parse('$fieldPathString($args_string);', Context.currentPos());
                case false: macro $fieldPath;
            }
            var functionBody = validations;

            if (field.isMagicDeferred()) {
                Util.debug('$name is deferred');
                var loader = field.getDeferredLoaderClass();
                var loaderExpression = field.getDeferredLoaderExpression();
                if (field.getFunctionBody() != null) {
                    Context.warning("Function body will be totally ignored in GraphQL deferred loader", f.pos);
                }

                var idExpr = switch [loaderExpression, field.argNames.length] {
                    case [null, 1]: macro $i{ field.argNames[0] };
                    case [null, _]: throw new Error("Deferred loader without expression must have exactly one argument", f.pos);
                    case [loader, _]: loader;
                }
                var returnType = field.getFunctionReturnType();

                var getResult = switch (Util.getTarget()) {
                    case Php: macro {
                            var id = $idExpr;
                            $loader.add(@:pos(f.pos) id);
                            return new graphql.externs.Deferred(() -> {
                                var result : $returnType = $loader.getValue(@:pos(f.pos) id);
                                $b{postValidations};
                                return result;
                            });
                        };
                    case Javascript: macro {
                            var id = $idExpr;
                            return $loader.loader.load(id).then((result) -> {
                                $b{postValidations};
                                return result;
                            });
                        }
                }
                functionBody = functionBody.concat([
                    macro return $getResult
                ]);
            } else {
                functionBody = functionBody.concat([
                    macro var result = $getResult
                ]).concat(postValidations).concat([
                    macro return result
                ]);
            }

            var resolve = switch [validationsCount, postValidationsCount, field.isStatic(), field.isFunction, Context.defined("gql_explicit_resolvers")] {
                case [0, 0, false, false, false]: {
                        // Add @:keep metadata to fields without explicit resolvers, to prevent DCE removing them
                        f.meta.push({name:":keep", pos: Context.currentPos()});
                        // Prevents creation of redundant anonymous function that simply returns the property value
                        // (This is already the behaviour of the server when no/null callback is provided)
                        macro null;
                    }
                default: macro (obj : $objectType, args : graphql.externs.NativeArray, ctx) -> {
                        $b{ functionBody }
                    }
            }

            var field:ExprOf<GraphQLField> = macro {
                name: $v{f.name},
                type: ${ field.getType() },
                description: ${ field.getDoc() },
                deprecationReason: ${ field.getDeprecationReason() },
                args: graphql.Util.processArgs( ${ field.args } ),
                resolve: $resolve
            }
            return field;
        }
        return null;
    }
    #end
}
