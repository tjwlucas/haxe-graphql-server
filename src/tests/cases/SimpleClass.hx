package tests.cases;

@:graphql
class SimpleClass {
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
    @:deprecated('With a deprecation reason')

    public var deprecated_string_field:String;

    public var int_field:Int;
}
