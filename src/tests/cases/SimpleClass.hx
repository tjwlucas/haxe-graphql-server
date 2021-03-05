package tests.cases;

import graphql.GraphQLObject;

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
