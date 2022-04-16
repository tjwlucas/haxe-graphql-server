package graphql.externs;

#if php
import php.NativeArray;
#end

@:native('GraphQL\\Utils\\SchemaPrinter')
extern class SchemaPrinter {
    public static function doPrint(schema:Schema, ?options:NativeArray) : String;
}