package tests.cases;

import graphql.IDType;
import sys.io.File;
import graphql.GraphQLServer;
import graphql.GraphQLObject;

using Type;
using StringTools;

class SchemaPrinterTest extends utest.Test {
    var server : GraphQLServer;
    function setup() {
        var obj = new SchemaPrintTestObject();
        server = new GraphQLServer(obj);
    }

    function specPrintSimpleClassSchema() {
        server.readSchema().trim() == MacroUtil.fileInclude('src/tests/cases/schemaPrinterTest.gql').trim();
    }
}

/**
    This is a simple GraphQL class test
**/
class SchemaPrintTestObject implements GraphQLObject {
    public function new(){}
    public var id:IDType;
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
    public var float_field:Float;
    public var int_array:Array<Int>;
    public var nested_int_array:Array<Array<Array<Int>>>;
    public var nullable_array_of_nullable_ints : Null<Array<Null<Int>>>;
    public var bool_field:Bool;

    @:mutation function doMutation(value : Bool = true) : Bool {
        return value;
    }

    @:mutation function nestedMutationObject() : SchemaPrintTestObject {
        return this;
    }
}
