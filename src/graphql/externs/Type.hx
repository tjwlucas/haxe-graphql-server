package graphql.externs;

@:native('GraphQL\\Type\\Definition\\Type')
extern class Type {
    public static function string() : Dynamic;
    public static function int() : Dynamic;
    public static function listOf(type:Dynamic) : Dynamic;
}