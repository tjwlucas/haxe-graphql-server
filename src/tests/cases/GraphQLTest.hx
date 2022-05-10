package tests.cases;

import graphql.externs.GraphQL;
import graphql.externs.Schema;
import graphql.TypeObjectDefinition;
import utest.Assert;

using graphql.Util;
import graphql.GraphQLObject;

/**
    This is the Query description
**/
@:typeName("Query")
class GraphQLInstanceTest implements GraphQLObject {
    public function new() {}

    /**
        String field comment
    **/
    public var string_field:Null<String> = 'This is an instance value';

    /**
        Object field comment
    **/
    public var object_field:OtherObject = new OtherObject();

    public var nested_int:Array<Array<Int>> = [[1], [5, 6]];
    public var float: Float = 7.2;
    public function greet(name:String = 'Bob') : String {
        return 'Hello, $name';
    }

    public function person(name:String) : Person {
        return new Person(name);
    }

    public function divide(x:Int, y:Int) : Float {
        return x / y;
    }
}

class OtherObject implements GraphQLObject {
    public function new() {}

    /**
        String field comment
    **/
    public var string_field:String = 'This is a value on the sub-object';
}

/**
    Person class
**/
class Person implements GraphQLObject {
    public function new(name:String) {
        _name = name;
    }

    var _name : String;
    /**
        States the person's name
    **/
    public function name():String {
        return 'This person has the name: $_name';
    }
}

class GraphQLTest extends utest.Test {
    var obj : GraphQLObject = new GraphQLInstanceTest();
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
        var result = GraphQL.executeQuery(schema, "query(
            $greet:String!,
            $person:String!,
            $x:Int!,
            $y:Int!,
            $queryTypeName:String!
            ){
                    __typename
                    __type(name:$queryTypeName) {
                        description
                    }
                    string_field
                    renamed:string_field
                    nested_int
                    object_field {
                        string_field
                    }
                    float
                    greet(name:$greet)
                    person(name:$person) {
                        __typename
                        name
                    }
                    divide(x: $x, y: $y)
                }", new GraphQLInstanceTest(), null, {
            greet: "Unit tests",
            person: "Herbert",
            x: 7,
            y: 2,
            queryTypeName: 'Query'
        }.associativeArrayOfObject());
        #if php
        Assert.equals(result.errors, [].toNativeArray());
        #elseif js
        Assert.isNull(result.errors);
        #end
        Assert.notNull(result.data);
        if (result.data != null) {
            var data:Map<String, Any> = result.data.hashOfAssociativeArray();

            var keys = [for (k in data.keys()) k];
            var expected_keys = ['__typename', '__type', 'string_field', 'renamed', 'nested_int', 'object_field', 'float', 'greet', 'person', 'divide'];
            Assert.same(keys, expected_keys, null, 'Key list mismatch. Got: $keys, expected: $expected_keys');

            data['__typename'] == 'Query';
            data['string_field'] == 'This is an instance value';
            data['renamed'] == result.data['string_field'];
            var expected = [[1].toNativeArray(), [5, 6].toNativeArray()].toNativeArray();
            #if php
            Assert.equals(expected, data['nested_int']);
            #else
            Assert.same(expected, data['nested_int']);
            #end
            data['float'] == 7.2;
            data['greet'] == 'Hello, Unit tests';
            data['divide'] == 3.5;

            Assert.notNull(data['object_field'], 'object_field is null');
            if (data['object_field'] != null) {
                var subobject = Util.hashOfAssociativeArray(data['object_field']);
                // Use same() assertion here instead of equality since haxe arrays are underlying objects which will be different instances
                var keys = [for (k in subobject.keys()) k];
                var expected_keys = ['string_field'];
                Assert.same(keys, expected_keys, null, 'Key list mismatch. Got: $keys, expected: $expected_keys');
                subobject['string_field'] == 'This is a value on the sub-object';
            }

            Assert.notNull(data['person'], 'person is null');
            if (data['person'] != null) {
                var subobject = Util.hashOfAssociativeArray(data['person']);
                // Use same() assertion here instead of equality since haxe arrays are underlying objects which will be different instances
                var keys = [for (k in subobject.keys()) k];
                var expected_keys = ['__typename', 'name'];
                Assert.same(keys, expected_keys, null, 'Key list mismatch. Got: $keys, expected: $expected_keys');
                subobject['__typename'] == 'Person';
                subobject['name'] == 'This person has the name: Herbert';
            }

            Assert.notNull(data['__type'], '__type is null');
            if (data['__type'] != null) {
                var subobject = Util.hashOfAssociativeArray(data['__type']);
                // Use same() assertion here instead of equality since haxe arrays are underlying objects which will be different instances
                var keys = [for (k in subobject.keys()) k];
                var expected_keys = ['description'];
                Assert.same(keys, expected_keys, null, 'Key list mismatch. Got: $keys, expected: $expected_keys');
                subobject['description'] == 'This is the Query description';
            }
        }
    }
}
