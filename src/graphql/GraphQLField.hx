package graphql;

using graphql.Util;
import graphql.externs.NativeArray;

/**
    Object representing a field on a GraphQL Type object
**/
@:structInit
class GraphQLField {
    /**
        Name of the GraphQL Field (on the schema)
    **/
    public var name: String;
    /**
        GraphQL type of the field on the schema
    **/
    public var type: Any;
    /**
        Field description on the schema
    **/
    public var description: Null<String>;
    /**
        If provided, will mark the field as deprecated on the schema,
        with the provided string as explanation
    **/
    public var deprecationReason: Null<String>;
    /**
        List of `GraphQLArgField`s, if the field expects arguments.
    **/
    public var args : NativeArray;
    /**
        Resolver function to yield the value returned to the GraphQL query
    **/
    public var resolve : Null<Any>;
}