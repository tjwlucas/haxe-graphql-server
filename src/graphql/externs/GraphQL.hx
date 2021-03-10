package graphql.externs;

import php.NativeArray;

@:native('GraphQL\\GraphQL')
extern class GraphQL {
    public static function executeQuery(schema: Schema, query: String, rootValue : Dynamic) : Dynamic;
}