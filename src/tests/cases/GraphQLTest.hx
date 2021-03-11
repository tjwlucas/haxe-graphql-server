package tests.cases;

import graphql.externs.GraphQL;
import graphql.externs.Schema;
import graphql.TypeObjectDefinition;
import utest.Assert;

using php.Lib;

import graphql.GraphQLObject;

@:typeName("Query")
class GraphQLInstanceTest extends GraphQLObject {
	public function new() {}

	/**
		String field comment
	**/
	public var string_field:String = 'This is an instance value';

	/**
		Object field comment
	**/
	public var object_field:OtherObject = new OtherObject();

    public var nested_int:Array<Array<Int>> = [[1], [5, 6]];
	public var float: Float = 7.2;
	

    public function greet(name:String) : String {
        return 'Hello, $name';
	}
	
	public function person(name:String) : Person {
        return new Person(name);
    }
	
	public function divide(x:Int, y:Int) : Float {
        return x / y;
    }
}

class OtherObject extends GraphQLObject {
	public function new() {}

	/**
		String field comment
	**/
	public var string_field:String = 'This is a value on the sub-object';
}

class Person extends GraphQLObject {
	public function new(name:String) {
		_name = name;
	}

	private var _name : String;
	/**
		String field comment
	**/
	public function name():String {
		return 'This person has the name: $_name';
	}
}

class GraphQLTest extends utest.Test {
	var obj = new GraphQLInstanceTest();
	var gql : TypeObjectDefinition;

	function setup() {
		gql = obj.gql;
	}
	
	function specGraphQLInstanceClass() {
		Assert.notNull(gql);
		Assert.notNull(gql.type);
	}

	function specQuerying() {
		var schema = new Schema({
			query: gql.type
		}.associativeArrayOfObject());
		var result = GraphQL.executeQuery(schema, '{
                    string_field
                    renamed:string_field
                    nested_int
                    object_field {
                        string_field
                    }
					float
					greet(name:"Unit tests")
					person(name:"Herbert") {
						name
					}
					divide(x: 7, y: 2)
                }', new GraphQLInstanceTest());
		result.errors == [].toPhpArray();
		Assert.notNull(result.data);
		if (result.data != null) {
			var data:Map<String, Dynamic> = result.data.hashOfAssociativeArray();

			var keys = [for (k in data.keys()) k];
			var expected_keys = ['string_field', 'renamed', 'nested_int', 'object_field', 'float', 'greet', 'person', 'divide'];
			Assert.same(keys, expected_keys, null, 'Key list mismatch. Got: $keys, expected: $expected_keys');

			data['string_field'] == 'This is an instance value';
			data['renamed'] == result.data['string_field'];
            data['nested_int'] == [[1].toPhpArray(), [5, 6].toPhpArray()].toPhpArray();
			data['float'] == 7.2;
			data['greet'] == 'Hello, Unit tests';
			data['divide'] == 3.5;

			Assert.notNull(data['object_field'], 'object_field is null');
			if (data['object_field'] != null) {
				var subobject = Lib.hashOfAssociativeArray(data['object_field']);
				// Use same() assertion here instead of equality since haxe arrays are underlying objects which will be different instances
				var keys = [for (k in subobject.keys()) k];
				var expected_keys = ['string_field'];
				Assert.same(keys, expected_keys, null, 'Key list mismatch. Got: $keys, expected: $expected_keys');
				subobject['string_field'] == 'This is a value on the sub-object';
			}
			
			Assert.notNull(data['person'], 'person is null');
			if (data['person'] != null) {
				var subobject = Lib.hashOfAssociativeArray(data['person']);
				// Use same() assertion here instead of equality since haxe arrays are underlying objects which will be different instances
				var keys = [for (k in subobject.keys()) k];
				var expected_keys = ['name'];
				Assert.same(keys, expected_keys, null, 'Key list mismatch. Got: $keys, expected: $expected_keys');
				subobject['name'] == 'This person has the name: Herbert';
			}
		}
	}
}
