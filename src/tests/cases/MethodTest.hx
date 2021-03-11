package tests.cases;

import graphql.GraphQLTypes;
import graphql.GraphQLField;
import graphql.GraphQLObject;

using tests.Util;

class MethodTest extends utest.Test {
    var fields: Array<GraphQLField>;
    function setup() {
        fields = @:privateAccess MethodTestObject.gql.fields;
    }
    function specMethodTestGreet() {
        var field = fields.getFieldDefinitionByName('greet');
        field.type == GraphQLTypes.String;
        var arg : php.NativeArray = field.args[0];
        arg['name'] == 'name';
        arg['type'] == GraphQLTypes.String;
    } 
    function specMethodTestAdd() {
        var field = fields.getFieldDefinitionByName('add');
        field.type == GraphQLTypes.Float;
        var arg : php.NativeArray = field.args[0];
        arg['name'] == 'x';
        arg['type'] == GraphQLTypes.Float;

        var arg : php.NativeArray = field.args[1];
        arg['name'] == 'y';
        arg['type'] == GraphQLTypes.Float;
    } 
    function specMethodTestRandomList() {
        var field = fields.getFieldDefinitionByName('randomList');
        Std.string(field.type) == '[Float]';
        var arg : php.NativeArray = field.args[0];
        arg['name'] == 'n';
        arg['type'] == GraphQLTypes.Int;
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
        return [for (i in 1...n) Math.random()];
    }
}