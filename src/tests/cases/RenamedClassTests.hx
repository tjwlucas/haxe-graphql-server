package tests.cases;

import graphql.GraphQLTypes;
import utest.Assert;
import utest.Test;

import graphql.GraphQLObject;


@:typeName('RenamedForGraphQL')
class RenamedClass extends GraphQLObject {
    public var string : String = "This is a string";
}

class RenamedClassTests extends Test {
    var type = RenamedClass;
    function specTypeExists() {
        Assert.notNull(type.gql);
    }

    @:depends(specTypeExists)
    function specTypeName() {
        @:privateAccess type.gql.type_name == 'RenamedForGraphQL';
    }

    @:depends(specTypeExists)
    function specFields() {
        var fields = @:privateAccess type.gql.fields;
        var field = Util.getFieldDefinitionByName(fields, 'string');
        field.type == GraphQLTypes.String;
        field.deprecationReason == null;
        field.description == null;
        field.name == 'string';
    }
}