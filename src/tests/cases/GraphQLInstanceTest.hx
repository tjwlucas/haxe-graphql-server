package tests.cases;

import graphql.GraphQLObject;

@:typeName("Query")
class GraphQLInstanceTest extends GraphQLObject {
    /**
        String field comment
    **/
    public var string_field:String = 'This is an instance value';
    /**
        Object field comment
    **/
    public var object_field:SimpleClass;
}