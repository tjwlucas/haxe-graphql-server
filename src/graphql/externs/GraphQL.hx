package graphql.externs;

#if php @:native("GraphQL\\GraphQL")
#elseif js @:jsRequire("graphql")
#end
extern class GraphQL {
    #if js inline #end
    public static function executeQuery(schema: Schema, query: String, rootValue : Dynamic, ?contextValue : Dynamic, ?variables: NativeArray, ?operationName:String) : ExecutionResult
    #if js {
        var ast = Language.parse(query);
        var invalidErrors = validate(schema, ast);
        if(invalidErrors.length > 0) {
            return {
                errors: invalidErrors
            };
        } else {
            return execute({
                schema: schema,
                document: ast,
                rootValue: rootValue,
                contextValue: contextValue,
                variableValues: variables,
                operationName: operationName
            });
        }
    }
    #end;

    #if js
    static function execute(parameters: {
        schema: Schema, document: JsDocument, ?rootValue:Dynamic, ?contextValue:Dynamic, ?variableValues: NativeArray, ?operationName: String
    }) : ExecutionResult;

    static function validate(schema: Schema, document: JsDocument) : Array<Error>;
    #end
}

#if js
    extern class JsDocument {}

    @:jsRequire("graphql")
    extern class Language {
        public static function parse(source:String, ?options:Dynamic) : JsDocument;
    }
#end