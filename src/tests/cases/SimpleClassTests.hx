package tests.cases;

import graphql.externs.GraphQL;
import graphql.GraphQLField;
import graphql.TypeObjectDefinition;
import utest.Assert;
import graphql.GraphQLTypes;
import graphql.GraphQLObject;

using Type;

class SimpleClassTests extends utest.Test {

    var fields : Array<GraphQLField>;
    var gql : TypeObjectDefinition;

    function setup() {
        @:privateAccess fields = new SimpleClass().gql.fields();
        gql = new SimpleClass().gql;
    }

	function specTypes() {
        GraphQLTypes.String == graphql.externs.Type.string();
        GraphQLTypes.Int == graphql.externs.Type.int();
        GraphQLTypes.Float == graphql.externs.Type.float();

        // Test they output the expected Graphql types
        Std.string(GraphQLTypes.String) == 'String';
        Std.string(GraphQLTypes.Int) == 'Int';
        Std.string(GraphQLTypes.Float) == 'Float';

        Std.string(GraphQLTypes.Array(GraphQLTypes.String)) == '[String]';
        Std.string(GraphQLTypes.Array(GraphQLTypes.Int)) == '[Int]';
        Std.string(GraphQLTypes.Array(GraphQLTypes.Float)) == '[Float]';

        Std.string(GraphQLTypes.NonNull(GraphQLTypes.Array(GraphQLTypes.String))) == '[String]!';
        Std.string(GraphQLTypes.NonNull(GraphQLTypes.Array(GraphQLTypes.Int))) == '[Int]!';
        Std.string(GraphQLTypes.NonNull(GraphQLTypes.Array(GraphQLTypes.Float))) == '[Float]!';

        Std.string(GraphQLTypes.NonNull(GraphQLTypes.Array(GraphQLTypes.NonNull(GraphQLTypes.Int)))) == '[Int!]!';

        // Arbitrary Nesting
        Std.string(GraphQLTypes.Array(GraphQLTypes.Array(GraphQLTypes.Array(GraphQLTypes.String)))) == '[[[String]]]';
    }
    
    function specGraphQLField() {
        Assert.isOfType(gql, TypeObjectDefinition);
        @:privateAccess gql.type_name == 'SimpleClass';

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
        Std.string(field.type) == 'String!';
        field.description == 'This is the `simple_string_field` documentation';
        field.deprecationReason == null;
    }

    function specHiddenFieldNotInSchema() {
        Assert.isNull(Util.getFieldDefinitionByName(fields, 'hidden_field'));
        Assert.isNull(Util.getFieldDefinitionByName(fields, 'toString'));
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
            Std.string(field.type) == 'Int!';
        }
    }

    function specIntArrayField() {
        var field = Util.getFieldDefinitionByName(fields, 'int_array');
        Assert.notNull(field);
        if(field != null) {
            Std.string(field.type) == '[Int!]!';
        }
    }

    function specNestedIntArrayField() {
        var field = Util.getFieldDefinitionByName(fields, 'nested_int_array');
        Assert.notNull(field);
        if(field != null) {
            var field = Util.getFieldDefinitionByName(fields, 'nested_int_array');
            Std.string(field.type) == '[[[Int!]!]!]!';
        }
    }

    function specFloatField() {
        var field = Util.getFieldDefinitionByName(fields, 'float_field');
        Assert.notNull(field, 'float_field is missing');
        if(field != null) {
            Std.string(field.type) == 'Float!';
        }
    }

    function specNullableString() {
        var field = Util.getFieldDefinitionByName(fields, 'nullable_string');
        Assert.notNull(field, 'nullable_string is missing');
        if(field != null) {
            Std.string(field.type) == 'String';
        }
    }

    function specNullableArrayOfInts() {
        var field = Util.getFieldDefinitionByName(fields, 'nullable_array_of_ints');
        Assert.notNull(field, 'nullable_array_of_ints is missing');
        if(field != null) {
            Std.string(field.type) == '[Int!]';
        }
    }

    function specNullableArrayOfNullableInts() {
        var field = Util.getFieldDefinitionByName(fields, 'nullable_array_of_nullable_ints');
        Assert.notNull(field, 'nullable_array_of_nullable_ints is missing');
        if(field != null) {
            Std.string(field.type) == '[Int]';
        }
    }

    function specBoolField() {
        var field = Util.getFieldDefinitionByName(fields, 'bool_field');
        Assert.notNull(field, 'bool_field is missing');
        if(field != null) {
            Std.string(field.type) == 'Boolean!';
        }
    }

    function specOptionalString() {
        var field = Util.getFieldDefinitionByName(fields, 'optional_string');
        Assert.notNull(field, 'optional_string is missing');
        if(field != null) {
            Std.string(field.type) == 'String';
        }
    }

    function specOptionalArrayOfInts() {
        var field = Util.getFieldDefinitionByName(fields, 'optional_array_of_ints');
        Assert.notNull(field, 'optional_array_of_ints is missing');
        if(field != null) {
            Std.string(field.type) == '[Int!]';
        }
    }

    function specObjectDescription() {
        gql.description == 'This is a simple GraphQL class test';
    }

    function specStructInitClass() {
        var object : SimpleStructClass = {int_value: 32};
        object.gql.description == 'A simple class using @:structInit instead of new()';
        @:privateAccess var theseFields = object.gql.fields();
        var field = Util.getFieldDefinitionByName(theseFields, 'int_value');
        Assert.notNull(field);
        field.resolve == null;
    }
    function specIdField() {
        var field = Util.getFieldDefinitionByName(fields, 'id');
        Assert.notNull(field, 'id is missing');
        if(field != null) {
            Std.string(field.type) == 'ID!';
        }
    }
}

/**
    This is a simple GraphQL class test
**/
class SimpleClass implements GraphQLObject {
    public function new(){}
    public var id:graphql.IDType;
	/**
		This is the `simple_string_field` documentation
	**/
    public var simple_string_field:String;

    /**
        This field should *not* appear in field definitions
    **/
    @:GraphQLHide
    public var hidden_field : String;

    public function toString() : String {
        return "This is a special case, and should NOT appear in the schema";
    }


    /**
        This field is a deprecated `String`
    **/
    @:deprecationReason('With a deprecation reason')

    public var deprecated_string_field:String;

    public var int_field:Int;
    public var float_field:Float;


    public var int_array:Array<Int>;


    public var nested_int_array:Array<Array<Array<Int>>>;


    public var nullable_string: Null<String>;
    @:optional public var optional_string: String;

    public var nullable_array_of_ints: Null<Array<Int>>;
    @:optional public var  optional_array_of_ints: Array<Int>;
    public var nullable_array_of_nullable_ints : Null<Array<Null<Int>>>;
    public var bool_field:Bool;

}

/**
    A simple class using @:structInit instead of new()
**/
@:structInit class SimpleStructClass implements GraphQLObject {
    public var int_value : Int = 32;
}