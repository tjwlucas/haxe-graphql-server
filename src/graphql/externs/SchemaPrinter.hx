package graphql.externs;

#if php
import php.NativeArray;
#end

#if php @:native('GraphQL\\Utils\\SchemaPrinter')
extern
#end
class SchemaPrinter {
    #if js inline #end public static function doPrint(schema:Schema) : String 
    #if js {
        return JsUtilities.printSchema(schema);
    }
    #end;
}