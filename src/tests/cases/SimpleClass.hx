package tests.cases;

@:build(graphql.TypeBuilder.build())
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
}
