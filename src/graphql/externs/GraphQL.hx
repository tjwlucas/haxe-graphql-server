package graphql.externs;

import graphql.externs.NativeArray;

#if php @:native('GraphQL\\GraphQL')
#elseif js @:jsRequire('graphql')
#end
extern class GraphQL {
    #if js inline #end
    public static function executeQuery(schema: Schema, query: String, rootValue : Dynamic, ?contextValue : Dynamic, ?variables: NativeArray, ?operationName:String) : ExecutionResult
    #if js
    {
        return execute({
            schema: schema,
            document: Language.parse(query),
            rootValue: rootValue,
            contextValue: contextValue,
            variableValues: variables,
            operationName: operationName
        });
    }
    #end;

    #if js
    static function execute(parameters: {
        schema: Schema, document: JsDocument, ?rootValue:Dynamic, ?contextValue:Dynamic, ?variableValues: NativeArray, ?operationName: String
    }) : ExecutionResult;
    #end
}

#if js
    extern class JsDocument {}

    @:jsRequire('graphql')
    extern class Language {
        public static function parse(source:String, ?options:Dynamic) : JsDocument;
    }
#end