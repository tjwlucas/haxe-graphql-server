package graphql.externs;

import php.NativeArray;

@:native('GraphQL\\Utils\\SchemaPrinter')
extern class SchemaPrinter {
    public static function doPrint(schema:Schema, ?options:NativeArray) : String;
}