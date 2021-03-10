package tests.cases;

import graphql.GraphQLField;
import graphql.TypeObjectDefinition;
import utest.Assert;
import graphql.GraphQLTypes;
import graphql.GraphQLObject;

using Type;

class SimpleClassTests extends utest.Test {

    var fields : Array<GraphQLField>;

    function setup() {
        @:privateAccess fields = SimpleClass.gql.fields;
    }

	function specTypes() {
        GraphQLTypes.String == graphql.externs.Type.string();
        GraphQLTypes.Int == graphql.externs.Type.int();
    }
    
    function specGraphQLField() {
        Assert.isOfType(SimpleClass.gql, TypeObjectDefinition);
        @:privateAccess SimpleClass.gql.type_name == 'SimpleClass';

        Assert.isOfType(fields, Array);
        for (f in fields) {
            Assert.isOfType(f.name, String);
        }
    }

    function specSimpleClassSimpleFieldString() {
        var field = Util.getFieldDefinitionByName(fields, 'simple_string_field');
        Assert.notNull(field);
    }

    @:depends(specSimpleClassSimpleFieldString)
    function specSimpleClassSimpleFieldStringValues() {
        var field = Util.getFieldDefinitionByName(fields, 'simple_string_field');
        field.type == GraphQLTypes.String;        
        field.description == 'This is the `simple_string_field` documentation';
        field.deprecationReason == null;
    }

    function specHiddenFieldNotInSchema() {
        Assert.isNull(Util.getFieldDefinitionByName(fields, 'hidden_field'));
    }

    function specDeprecatedStringField() {
        var field = Util.getFieldDefinitionByName(fields, 'deprecated_string_field');
        Assert.notNull(field);
        if(field != null) {
            field.deprecationReason == 'With a deprecation reason';
        }
    }

    function specIntField() {
        var field = Util.getFieldDefinitionByName(fields, 'int_field');
        Assert.notNull(field, 'int_field is missing');
        if(field != null) {
            field.type == GraphQLTypes.Int;
        }
    }

    function specIntArrayField() {
        var field = Util.getFieldDefinitionByName(fields, 'int_array');
        Assert.notNull(field);
        if(field != null) {
            Std.string(field.type) == '[Int]';
        }
    }

    function specNestedIntArrayField() {
        var field = Util.getFieldDefinitionByName(fields, 'nested_int_array');
        Assert.notNull(field);
        if(field != null) {
            var field = Util.getFieldDefinitionByName(fields, 'nested_int_array');
            Std.string(field.type) == '[[[Int]]]';
        }
    }
}

class SimpleClass extends GraphQLObject {
	/**
		This is the `simple_string_field` documentation
	**/
    public var simple_string_field:String;

    /**
        This field should *not* appear in field definitions
    **/
    @:GraphQLHide
    public var hidden_field : String;


    /**
        This field is a deprecated `String`
    **/
    @:deprecationReason('With a deprecation reason')

    public var deprecated_string_field:String;

    public var int_field:Int;


    public var int_array:Array<Int>;


    public var nested_int_array:Array<Array<Array<Int>>>;
}