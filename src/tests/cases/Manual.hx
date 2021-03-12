package tests.cases;

import php.Session;
import sys.io.File;
import haxe.Json;
import graphql.GraphQLError;
import graphql.GraphQLObject;
import graphql.GraphQLObjectInterface;
import graphql.GraphQLServer;
using Math;

class Manual {
    static function main() {
        var variables : Dynamic;
        try{
            var input = Json.parse(File.getContent('php://input'));
            variables = input.variables != null ? input.variables : {};
        } catch (e) {
            variables = {};
        }

        var base_object = new ManualTest();
        var server = new GraphQLServer(base_object, null, variables);
        server.run();
    }

	static function __init__() {
		php.Global.require_once('vendor/autoload.php');
	}
}

@:typeName("Query")
class ManualTest extends GraphQLObject implements GraphQLObjectInterface {
    public function new() {}

    /**
        Will always return true
    **/
    public var loaded:Bool = true;

    @:validationContext(var capName = (name:String).toUpperCase())
    @:validationContext(var disallowed = 'me'.toUpperCase())
    @:validate(capName != disallowed, 'You are not allowed to greet "$name"')
    public function greet(name : String = 'Sir') : String {
        return 'Hello, $name';
    }

    @:validationContext(var nlimit = 1000)
    @:validate(n >= 0, 'n must be non-negative ($n given)')
    @:validate(n <= nlimit, 'n must be <= $nlimit ($n given)')
    @:validate(min <= max, 'min ($min) cannot be greater than max ($max)')
    @:validateResult( !result.contains(0), 'The result contains a 0 (${Std.string(result)})', "invalid_response" )
    public function randomInts(n : Int = 10, min : Int = 1, max : Int  = 10) : Null<Array<Int>> {
        return [for(i in 0...n) (Math.random() * (max - min + 1)).floor() + min];
    }
}