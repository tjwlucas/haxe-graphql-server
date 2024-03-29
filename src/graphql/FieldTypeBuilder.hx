package graphql;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.TypeTools;
using StringTools;
using haxe.macro.ExprTools;
using graphql.macro.Util;

/**
    Class of macros to build the individual fields on auto-built classes implementing `GraphQLObjec`
**/
class FieldTypeBuilder {

    /**
        The default context variable name
    **/
    static inline final CTX_DEFAULT_VARIABLE_NAME = "ctx";
    /**
        "Not a function" error message
    **/
    static inline final NOT_A_FUNCTION = "Not a function";

    /**
        Name of the compiler flag to change the default name of the context variable
    **/
    static inline final GQL_CONTEXT_VARIABLE = "gql_context_variable";

    /**
        The AST field this FieldBuilder is being build based upon.
    **/
    var field:Field;

    static final TYPES_CLASS = Context.getType("graphql.GraphQLTypes");
    /**
        String list of the names of the properties on the `graphql.GraphQLTypes` class,
        used to determine if a type is a specified primitive scalar type
    **/
    static final PRIMITIVE_TYPE_NAMES = TypeTools.getClass(TYPES_CLASS).statics.get().map((field) -> return field.name);

    var type : Expr;

    /**
        List of identifier expressions, if the field is a function.
        e.g. for `doSomething(message:String, count:Int, ctx:ContextObject)`,
        will equal:
        ```
        [
            macro message,
            macro count,
            macro ctx
        ]
        ```
    **/
    public var args : Expr = macro [];

    /**
        If field is a function returns a list of strings containing the names of the arguments.

         e.g. for `doSomething(message:String, count:Int, ctx:ContextObject)`,
        will equal: `["message", "count", "ctx"]`
    **/
    public var argNames: Array<String> = [];

    /**
        Returns true if this field is a function (as opposed to a variable)
    **/
    public var isFunction = false;
    var isDeferred = false;

    /**
        Specifies whether this FieldTypeBuilder represents the `Query` or `Mutation` version of this field
    **/
    var queryType : GraphQLObjectType;

    public function new(field:Field, type: GraphQLObjectType = Query) {
        this.field = field;
        this.queryType = type;
        if (isVisible()) {
            buildFieldType();
        }
    }

    /**
        Get an array of expressions defining variables from passed arguments (and context variable).

        e.g. From the function with signature: `doSomething(message:String, count:Int)`,
        the returned array would contain
        ```
        [
            macro var message = args.message,
            macro var count = args.count
        ]
        ```
    **/
    public function getArgumentVariableDefinitions() {
        var ctx_var_name = getContextVariableName();
        var argumentVariableDefinitions = [];
        for (i => f in argNames) {
            var thisArgType = getFunctionArgType(i);
            var defined = if (f == ctx_var_name) {
                macro ctx;
            } else {
                macro args.$f;
            }
            argumentVariableDefinitions.push(macro var $f : $thisArgType = $defined);
        }
        // Add renamed context variable to context, even when not present in function argument list
        if (!argNames.contains(ctx_var_name) && ctx_var_name != CTX_DEFAULT_VARIABLE_NAME) {
            var f = ctx_var_name;
            argumentVariableDefinitions.insert(0, macro var $f = ctx);
        }
        return argumentVariableDefinitions;
    }

    /**
        Checks if passed name represents a GraphQL primitive type, if not,
        checks if it is a class representing a GraphQLObject. In either of these cases, returns the corresponding type.

        @param typeParam String representation of type to be checked
    **/
    function getBaseType(typeParam : String) {
        return switch (PRIMITIVE_TYPE_NAMES) {
            case a if (a.contains(typeParam)): macro graphql.GraphQLTypes.$typeParam;
            case _: try {
                    var cls = Context.getType(typeParam).getClass();
                    switch (this.queryType) {
                        case (Query): macro $i{cls.name}._gql.type;
                        case (Mutation): macro $i{cls.name}._gql.mutationType;
                    }
                } catch (e) {
                    throw unsupportedTypeError();
                }
        }
    }

    function unsupportedTypeError() {
        new Error('Type declaration ($type) not supported in the GraphQL type builder', field.pos);
    }

    function typeFromTPath(name: String, ?params: Array<TypeParam>, nullable = false) {
        return switch (name) {
            case("Array"): {
                    var arrayOf = arrayType(params);
                    var base_type = getBaseType(name);
                    var array_expr = macro $base_type($arrayOf);
                    if (nullable) {
                        macro $array_expr;
                    } else {
                        macro graphql.GraphQLTypes.NonNull($array_expr);
                    }
                }
            case ("Null"): {
                    var base_type = nullableType(params);
                    macro $base_type;
                }
            case ("Deferred" | "Promise"): {
                    isDeferred = true;
                    var deferredOf = arrayType(params);
                    macro $deferredOf;
                }
            default: {
                    var base_type = getBaseType(name);
                    if (nullable) {
                        macro $base_type;
                    } else {
                        macro graphql.GraphQLTypes.NonNull($base_type);
                    }
                }
        }
    }

    function nullableType(params: Array<TypeParam>) {
        var nullableType : Expr;
        switch (params[0]) {
            case(TPType(TPath({name: a, params: p}))):
                nullableType = typeFromTPath(a, p, true);
            default:
                throw unsupportedTypeError();
        }
        return nullableType;
    }

    function arrayType(params: Array<TypeParam>) {
        var arrayType : Expr;
        switch (params[0]) {
            case(TPType(TPath({name: a, params: p}))):
                arrayType = typeFromTPath(a, p);
            default:
                throw unsupportedTypeError();
        }
        return arrayType;
    }

    function functionReturnType(?ret: ComplexType) {
        var returnType : Expr;
        switch (ret) {
            case(TPath({name: a, params: p})):
                returnType = typeFromTPath(a, p);
            default:
                throw unsupportedTypeError();
        }
        return returnType;
    }

    /**
        Expression defining a type compatible with the graphql output.
    **/
    public function getType() {
        return type;
    }

    function getContextVariableName() {
        var expr : Expr;
        if (hasMeta(ContextVar)) {
            expr = getMeta(ContextVar).params[0];
        } else {
            var context_variable_name = Context.defined(GQL_CONTEXT_VARIABLE) ? Context.definedValue(GQL_CONTEXT_VARIABLE) : CTX_DEFAULT_VARIABLE_NAME;
            expr = macro $i{context_variable_name};
        }
        return expr.toString();
    }

    function buildFieldType() : Void {
        switch (field.kind) {
            case(FVar(TPath({name: a, params: p}))):
                type = typeFromTPath(a, p, hasMeta(Optional));
            case(FFun({ret: return_type, args: args})):
                isFunction = true;
                var argList = buildArgList(args);
                this.args = macro $a{ argList };
                type = functionReturnType(return_type);
            default:
                throw unsupportedTypeError();
        }
    }

    function buildArgList(arguments : Array<FunctionArg>) {
        var arg_list : Array<ExprOf<Any>> = [];
        for (arg in arguments) {
            switch ([arg.type, arg.name]) {
                case [TPath({name: a, params: p}), name] if (name != getContextVariableName()): {
                        argNames.push(arg.name);
                        var defaultValue = arg.value != null ? arg.value : macro null;
                        var arg_field : ExprOf<GraphQLArgField> = macro {
                            var arg : graphql.GraphQLArgField = {
                                type: ${ typeFromTPath(a, p, arg.opt ? true : arg.value != null) },
                                name: $v{ arg.name },
                                description: ${ getDoc(arg) }
                            };
                            if ($defaultValue != null) {
                                arg.defaultValue = $defaultValue;
                            }
                            arg;
                        };
                        arg_list.push( macro graphql.Util.associativeArrayOfObject($arg_field));
                    }
                case [TPath({name: a, params: p}), name]: argNames.push(name);
                default:
                    throw unsupportedTypeError();
            }
        }
        return arg_list;
    }

    /**
        Returns the documentation defined for this field. (Either in a doc comment, or metadata)
    **/
    public function getDoc(?f:{meta:Metadata}) {
        var description = switch [getMeta(DocMeta, f), f] {
            case [null, null]: {
                    var comment = this.field.doc != null ? this.field.doc.trim() : null;
                    macro $v{ comment };
                }
            case [null, _]: macro null;
            case [meta, _] if (meta.params != null && meta.params.length > 0): meta.params[0];
            default: macro null;
        }
        return description;
    }

    /**
        Returns a string expression for the deprecation reason, if provided using the @:deprecated metadata
    **/
    public function getDeprecationReason():ExprOf<String> {
        var deprecationReason = macro null;
        if (hasMeta(Deprecated)) {
            deprecationReason = getMeta(Deprecated).params[0];
        }
        return deprecationReason;
    }

    /**
        Returns true if field is static
    **/
    public function isStatic() : Bool {
        return field.access.contains(AStatic);
    }

    /**
        Returns true if the field is a 'magic deferred' (i.e. Using the `@:deferred` metadata)
    **/
    public function isMagicDeferred() : Bool {
        return hasMeta(Deferred);
    }

    /**
        Returns the first expression passed to `@:deferred` metadata
    **/
    public function getDeferredLoaderClass() {
        return getMeta(Deferred).params[0];
    }

    /**
        Returns the first expression passed to `@:deferred` metadata
    **/
    public function getDeferredLoaderExpression() {
        return getMeta(Deferred).params[1];
    }

    /**
        Returns expression of the function body (If the field is a function)
    **/
    public function getFunctionBody() {
        return getFunctionInfo().expr;
    }

    /**
        Returns the `ComplexType` of the return value of the function (If the field is a function)
    **/
    public function getFunctionReturnType() : ComplexType {
        return getFunctionInfo().ret;
    }

    /**
        Retrieves type data for this field, if it is a function. Throws an error if not a function.
    **/
    function getFunctionInfo() {
        return switch (field.kind) {
            case FFun(a): a;
            default: throw new Error(NOT_A_FUNCTION, field.pos);
        }
    }

    /**
        Returns the ComplexType of the specified function argument

        @param i Index of function argument to retrieve the type for
    **/
    function getFunctionArgType(i:Int = 0) {
        return getFunctionInfo().args[i].type;
    }

    /**
        Returns true if the field being build contains MetaData matching the provided name. (Runtime or buildtime versions)

        @param name Name of meta data to check for
        @param allowMultiple If set to false, throws an error if the specified metadata occurs more than once on the field
    **/
    function hasMeta(name : FieldMetadata, allowMultiple = false) {
        var found = false;
        for (meta in field.meta) {
            var nameMatches = [':$name', name].contains(meta.name);
            found = switch [nameMatches, allowMultiple, found] {
                case [true, false, true]: throw new Error('Duplicate metadata found for $name on ${field.name}', meta.pos);
                case [true, _, _]: true;
                case [false, _, _]: found;
            }
        }
        return found;
    }

    /**
        Retrieves the *first* metadata item with the provided name (with or without preceding `:`)
    **/
    function getMeta(name : FieldMetadata, ?field:{meta:Metadata}) {
        return getMetas(name, field)[0];
    }

    /**
        Retrieves list of metadata with the given name (with or without preceding `:`)
    **/
    function getMetas(name : FieldMetadata, ?field:{meta:Metadata}) {
        if (field == null) {
            field = this.field;
        }
        return field.meta.filterMetas(name);
    }

    /**
        Determines if the field should be visible in the GraphQL Schema
    **/
    public function isVisible() {
        return switch [hasMeta(Hide), field.name, queryType, hasMeta(MutationField), hasMeta(QueryField)] {
            // If not explicitly specified, for query or mutation, use public field access
            // Otherwise, base purely on metadata
            case [true, _, _, _, _]: false; // Never show if flagged as hidden
            case [false, "new" | "toString", _, _, _]: false; //Always exclude 'special methods'
            case [false, _, Query, true, false]: false;
            case [false, _, Query, _, true]: true;
            case [false, _, Query, false, false]: field.access.contains(APublic);
            case [false, _, Mutation, true, _]: true;
            case [false, _, Mutation, false, _]: false;
        }
    }

    /**
        Retrieves a list of all attached validate metadata entries and returns a list of validation expressions based on them.

        @param meta Which metadata values to look at. Defaults to `Validate`, but might also be `ValidateAfter`.
    **/
    public function getValidators(meta : FieldMetadata = Validate) : Array<Expr> {
        var checks : Array<Expr> = [];
        if (hasMeta(meta, true)) {
            var validations = getMetas(meta);
            for (v in validations) {
                var check = v.params[0];
                var message = v.params.length > 1 ? v.params[1] : macro "Validation failed";
                var extension = v.params.length > 2 ? v.params[2] : macro "validation";
                var clientSafe = v.params.length > 3 ? v.params[3] : macro null;
                var expr = macro {
                    if (!$check) {
                        throw new graphql.GraphQLError($message, $extension, $clientSafe);
                    }
                }
                checks.push(expr);
            }
        }
        return checks;
    }

    /**
        Gets the validation context metadata, if present, and adds it to the validation expression list, before any of the validations are run.
    **/
    public function getValidationContext() : Array<Expr> {
        var expressions : Array<Expr> = [];
        if (hasMeta(ValidationContext, true)) {
            var validations = getMetas(ValidationContext);
            for (v in validations) {
                var expr = v.params[0];
                expressions.push(expr);
            }
        }
        return expressions;
    }
}
#end