package graphql.externs;

@:jsRequire("graphql")
extern class JsUtilities {
    public static function printSchema(schema:Schema): String;
}