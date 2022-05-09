package graphql.externs;

#if php
@:native("GraphQL\\Type\\Definition\\Type")
extern class Type {
    public static function string() : Dynamic;
    public static function int() : Dynamic;
    public static function float() : Dynamic;
    public static function boolean() : Dynamic;
    public static function id() : Dynamic;
    public static function listOf(type:Dynamic) : Dynamic;
    public static function nonNull(type:Dynamic) : Dynamic;
}
#elseif js
@:jsRequire("graphql")
extern class Type {
    static var GraphQLString : Dynamic;
    static var GraphQLInt : Dynamic;
    static var GraphQLFloat : Dynamic;
    static var GraphQLBoolean : Dynamic;
    static var GraphQLID : Dynamic;
    public static inline function string() : Dynamic {
        return GraphQLString;
    }
    public static inline function int() : Dynamic {
        return GraphQLInt;
    }
    public static inline function float() : Dynamic {
        return GraphQLFloat;
    }
    public static inline function boolean() : Dynamic {
        return GraphQLBoolean;
    }
    public static inline function id() : Dynamic {
        return GraphQLID;
    }
    public static inline function listOf(type:Dynamic) : Dynamic {
        return new GraphQLList(type);
    }
    public static inline function nonNull(type:Dynamic) : Dynamic {
        return new GraphQLNonNull(type);
    }
}

@:jsRequire("graphql", "GraphQLList")
extern class GraphQLList {
    public function new(type:Dynamic);
}

@:jsRequire("graphql", "GraphQLNonNull")
extern class GraphQLNonNull {
    public function new(type:Dynamic);
}
#end