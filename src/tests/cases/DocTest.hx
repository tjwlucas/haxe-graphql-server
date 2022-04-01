package tests.cases;

import graphql.GraphQLField;
import graphql.TypeObjectDefinition;
import graphql.GraphQLObject;

class DocTest extends utest.Test {

    var fields : Array<GraphQLField>;
    var gql : TypeObjectDefinition;

    function setup() {
        @:privateAccess fields = new DocTestObject().gql.fields;
        gql = new DocTestObject().gql;
    }

    function specDocTestObject() {
        var expected_docs = [
            'variable' => 'This is a variable comment',
            'metaVariable' => 'This is a meta doc',
            'functionComment' => 'This is a function comment',
            'functionMetaDoc' => 'This is a function meta doc',
            'metaRemovedVariable' => null,
            'functionMetaRemovedDoc' => null
        ];

        for(name => doc in expected_docs) {
            var field = Util.getFieldDefinitionByName(fields, name);
            field.description == doc;
        }
        gql.description == 'This is a class comment';
    }

    function specMetaClass() {
        new DocMetaTestObject().gql.description == 'This is added to meta';
        new DocMetaRemoveTestObject().gql.description == null;
    }
}

/**
    This is a class comment
**/
class DocTestObject implements GraphQLObject {
    public function new() {}
    /**
        This is a variable comment
    **/
    public var variable : String;

    /**
        Not used
    **/
    @:doc("This is a meta doc")
    public var metaVariable : String;
    
    /**
        Not used
    **/
    @:doc
    public var metaRemovedVariable : String;

    /**
        This is a function comment
    **/
    public function functionComment() : String {
        return "";
    };

    /**
        Not used
    **/
    @:doc("This is a function meta doc")
    public function functionMetaDoc() : String {
        return "";
    };

    /**
        Not used
    **/
    @:doc
    public function functionMetaRemovedDoc() : String {
        return "";
    };

}

/**
    This is a class comment
**/
@:doc("This is added to meta")
class DocMetaTestObject implements GraphQLObject {
    public function new() {}

    public var variable : String;
}

/**
    This is a class comment
**/
@:doc
class DocMetaRemoveTestObject implements GraphQLObject {
    public function new() {}

    public var variable : String;
}