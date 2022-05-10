package graphql;

import graphql.externs.Type;

@SuppressWarnings("checkstyle:ConstantName", "checkstyle:MethodName") // These constants come from type names, and must match
class GraphQLTypes {
    /**
        GraphQL Native Integer type
    **/
    public static final Int : Any = Type.int();
    /**
        GraphQL Native String type
    **/
    public static final String : Any = Type.string();
    /**
        GraphQL Native Float type
    **/
    public static final Float : Any = Type.float();
    /**
        GraphQL Native Boolean type
    **/
    public static final Bool : Any = Type.boolean();
    /**
        GraphQL Native ID type
    **/
    public static final IDType : Any = Type.id();
    /**
        Transforms passed type into a non-nullable type.

        @param type Any valid (nullable) GraphQL type
    **/
    public static function NonNull(type:Any) : Any {
        return Type.nonNull(type);
    }
    /**
        Transforms passed type into an Array of that type.

        @param type Any valid GraphQL type
    **/
    public static function Array(type:Any) : Any {
        return Type.listOf(type);
    }
}