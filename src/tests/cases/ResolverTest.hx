package tests.cases;

import graphql.GraphQLServer;
import graphql.GraphQLObject;

class ResolverTest extends utest.Test {
    var server : GraphQLServer;
    function setup() {
        var base = new ResolverTestObject();
        this.server = new GraphQLServer(base);
    }

    function specSimpleMethod() {
        var response = server.executeQuery('{simpleMethod}');
        response.data['simpleMethod'] == "This is a simple response";
    }
}


class ResolverTestObject extends GraphQLObject {
    public function new() {}

    public function simpleMethod() : String {
        return "This is a simple response";
    }
}