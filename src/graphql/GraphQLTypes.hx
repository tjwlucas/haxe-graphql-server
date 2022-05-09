package graphql;

import graphql.externs.Type;

@SuppressWarnings("checkstyle:ConstantName") // These constants come from type names, and must match
class GraphQLTypes {
    public static final Int = Type.int();
    public static final String = Type.string();
    public static final Float = Type.float();
    public static final Bool = Type.boolean();
    public static final IDType = Type.id();
    public static function NonNull(type:Dynamic) {
        return Type.nonNull(type);
    }
    public static function Array(type:Dynamic) {
        return Type.listOf(type);
    }
}