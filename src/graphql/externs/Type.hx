package graphql.externs;

#if php
@:native("GraphQL\\Type\\Definition\\Type")
extern class Type {
    public static function string() : Any;
    public static function int() : Any;
    public static function float() : Any;
    public static function boolean() : Any;
    public static function id() : Any;
    public static function listOf(type:Any) : Any;
    public static function nonNull(type:Any) : Any;
}
#elseif js
@:jsRequire("graphql")
extern class Type {
    static var GraphQLString : Any;
    static var GraphQLInt : Any;
    static var GraphQLFloat : Any;
    static var GraphQLBoolean : Any;
    static var GraphQLID : Any;
    public static inline function string() : Any {
        return GraphQLString;
    }
    public static inline function int() : Any {
        return GraphQLInt;
    }
    public static inline function float() : Any {
        return GraphQLFloat;
    }
    public static inline function boolean() : Any {
        return GraphQLBoolean;
    }
    public static inline function id() : Any {
        return GraphQLID;
    }
    public static inline function listOf(type:Any) : Any {
        return new GraphQLList(type);
    }
    public static inline function nonNull(type:Any) : Any {
        return new GraphQLNonNull(type);
    }
}

@:jsRequire("graphql", "GraphQLList")
extern class GraphQLList {
    public function new(type:Any);
}

@:jsRequire("graphql", "GraphQLNonNull")
extern class GraphQLNonNull {
    public function new(type:Any);
}
#end