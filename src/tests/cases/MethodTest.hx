package tests.cases;

import graphql.GraphQLTypes;
import graphql.GraphQLField;
import graphql.GraphQLObject;

using tests.Util;
using graphql.Util;

class MethodTest extends utest.Test {
    var fields: Array<GraphQLField>;
    function setup() {
        fields = @:privateAccess new MethodTestObject().gql.fields();
    }
    function specMethodTestGreet() {
        var field = fields.getFieldDefinitionByName('greet');
        Std.string(field.type) == 'String!';
        var arg = field.getArgMaps()[0];
        arg['name'] == 'name';
        Std.string(arg['type']) == 'String!';
        arg.exists('defaultValue') == false;
    }

    function specMethodTestAdd() {
        var field = fields.getFieldDefinitionByName('add');
        Std.string(field.type) == 'Float!';
        var arg = field.getArgMaps()[0];
        arg['name'] == 'x';
        Std.string(arg['type']) == 'Float!';
        arg.exists('defaultValue') == false;

        var arg = field.getArgMaps()[1];
        arg['name'] == 'y';
        Std.string(arg['type']) == 'Float!';
        arg.exists('defaultValue') == false;
    }

    function specMethodTestRandomList() {
        var field = fields.getFieldDefinitionByName('randomList');
        Std.string(field.type) == '[Float!]!';
        var arg = field.getArgMaps()[0];
        arg['name'] == 'n';
        Std.string(arg['type']) == 'Int!';
        arg.exists('defaultValue') == false;
    }

    function specMethodTestRandomListWithDefault() {
        var field = fields.getFieldDefinitionByName('randomListWithDefault');
        Std.string(field.type) == '[Float!]!';
        var args = field.getArgMaps();
        var arg = args[0];
        arg['name'] == 'n';
        Std.string(arg['type']) == 'Int';
        arg.exists('defaultValue') == true;
        arg['defaultValue'] == 5;
    }

    function specMethodWithPassedInContext() {
        var field = fields.getFieldDefinitionByName('addWithPassedInContext');
        Std.string(field.type) == 'Float!';
        var args = field.getArgMaps();
        args.length == 2;
        var arg = args[0];
        arg['name'] == 'x';
        Std.string(arg['type']) == 'Float!';
        var arg = args[1];
        arg['name'] == 'y';
        Std.string(arg['type']) == 'Float!';

        var field = fields.getFieldDefinitionByName('addWithPassedInCustomContext');
        Std.string(field.type) == 'Float!';
        var args = field.getArgMaps();
        args.length == 2;
        var arg = args[0];
        arg['name'] == 'x';
        Std.string(arg['type']) == 'Float!';
        var arg = args[1];
        arg['name'] == 'y';
        Std.string(arg['type']) == 'Float!';

        var field = fields.getFieldDefinitionByName('addWithPassedInContextArbitraryOrder');
        Std.string(field.type) == 'Float!';
        var args = field.getArgMaps();
        args.length == 2;
        var arg = args[0];
        arg['name'] == 'x';
        Std.string(arg['type']) == 'Float!';
        var arg = args[1];
        arg['name'] == 'y';
        Std.string(arg['type']) == 'Float!';
    }
    
    function specMethodTestGetFromId() {
        var field = fields.getFieldDefinitionByName('getFromId');
        Std.string(field.type) == 'String!';
        var arg = field.getArgMaps()[0];
        arg['name'] == 'id';
        Std.string(arg['type']) == 'ID!';
        arg.exists('defaultValue') == false;
    }
}

class MethodTestObject implements GraphQLObject {
    public function new(){}

    public function getFromId(id: graphql.IDType) : String {
        return 'Returning result from provided id ($id)';
    }

    public function greet(name:String) : String {
        return 'Hello, $name';
    }

    public function add(x:Float, y:Float) : Float {
        return x + y;
    }

    public function randomList(n:Int) : Array<Float> {
        return [for (i in 1...(n+1)) Math.random()];
    }

    public function randomListWithDefault(n:Int = 5) : Array<Float> {
        return [for (i in 1...(n+1)) Math.random()];
    }

    public function addWithPassedInContext(x:Float, y:Float, ctx:Dynamic) : Float {
        return x + y;
    }

    @:context(customContext)
    public function addWithPassedInCustomContext(x:Float, y:Float, customContext:Dynamic) : Float {
        return x + y;
    }

    public function addWithPassedInContextArbitraryOrder(x:Float, ctx:Dynamic, y:Float) : Float {
        return x + y;
    }
}