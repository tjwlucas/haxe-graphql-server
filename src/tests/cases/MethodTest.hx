package tests.cases;

import graphql.GraphQLTypes;
import graphql.GraphQLField;
import graphql.GraphQLObject;

using tests.Util;

class MethodTest extends utest.Test {
    var fields: Array<GraphQLField>;
    function setup() {
        fields = @:privateAccess new MethodTestObject().gql.fields;
    }
    function specMethodTestGreet() {
        var field = fields.getFieldDefinitionByName('greet');
        Std.string(field.type) == 'String!';
        var arg : php.NativeArray = field.args[0];
        arg['name'] == 'name';
        Std.string(arg['type']) == 'String!';
    } 
    function specMethodTestAdd() {
        var field = fields.getFieldDefinitionByName('add');
        Std.string(field.type) == 'Float!';
        var arg : php.NativeArray = field.args[0];
        arg['name'] == 'x';
        Std.string(arg['type']) == 'Float!';

        var arg : php.NativeArray = field.args[1];
        arg['name'] == 'y';
        Std.string(arg['type']) == 'Float!';
    } 
    function specMethodTestRandomList() {
        var field = fields.getFieldDefinitionByName('randomList');
        Std.string(field.type) == '[Float!]!';
        var arg : php.NativeArray = field.args[0];
        arg['name'] == 'n';
        Std.string(arg['type']) == 'Int!';
    }    
}

class MethodTestObject extends GraphQLObject {
    public function new(){}

    public function greet(name:String) : String {
        return 'Hello, $name';
    }

    public function add(x:Float, y:Float) : Float {
        return x + y;
    }

    public function randomList(n:Int) : Array<Float> {
        return [for (i in 1...(n+1)) Math.random()];
    }
}