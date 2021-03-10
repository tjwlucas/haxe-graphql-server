package tests.types;

import graphql.GraphQLObject;

@:typeName('RenamedForGraphQL')
class RenamedClass extends GraphQLObject {
    public var string : String = "This is a string";
}