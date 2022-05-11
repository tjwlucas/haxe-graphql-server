package tests.cases;

import graphql.externs.NativeArray;
import graphql.GraphQLServer;
import utest.Assert;
import utest.Test;

import graphql.GraphQLObject;

@:typeName('RenamedForGraphQL')
class RenamedClass implements GraphQLObject {
    public function new(){}
    public var string : String = "This is a string";
}

class NotRenamedClass implements GraphQLObject {
    public function new(){}
    public var string : String = "This is a string";
}

class RenamedClassTests extends Test {
    var type : GraphQLObject = new RenamedClass();
    function specTypeExists() {
        Assert.notNull(type.gql);
    }

    @:depends(specTypeExists)
    function specTypeName() {
        @:privateAccess type.gql.typeName == 'RenamedForGraphQL';
    }

    @:depends(specTypeExists)
    function specFields() {
        var fields = @:privateAccess type.gql.fields();
        var field = Util.getFieldDefinitionByName(fields, 'string');
        Std.string(field.type) == 'String!';
        field.deprecationReason == null;
        field.description == null;
        field.name == 'string';
    }

    function specQuerySchema() {
        var base = new RenamedClass();
        var server = new GraphQLServer(base);
        var result = server.executeQuery('{__typename}');
        var data : NativeArray = result.data;
        data.__typename == 'RenamedForGraphQL';

        var base = new NotRenamedClass();
        var server = new GraphQLServer(base);
        var result = server.executeQuery('{__typename}');
        var data : NativeArray = result.data;
        data.__typename == 'NotRenamedClass';
    }
}