package graphql;

typedef GraphQLArgField = {
    /**
        Name of the argument field on the GraphQL Schema
    **/
    var name: String;
    /**
        GraphQL type of the input field on the schema
    **/
    var type: Any;
    /**
        Description for the argument field
    **/
    var description: Null<String>;
    /**
        (Optional) Default value passed in, if none provided
    **/
    var ?defaultValue : Null<Any>;
}