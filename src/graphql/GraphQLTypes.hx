package graphql;

import graphql.externs.Type;

class GraphQLTypes {
    public static var Int = Type.int();
    public static var String = Type.string();
    public static var Float = Type.float();
    public static var Bool = Type.boolean();
    public static function NonNull(type:Dynamic) {
        return Type.nonNull(type);
    }
    public static function Array(type:Dynamic) {
        return Type.listOf(type);
    }
}