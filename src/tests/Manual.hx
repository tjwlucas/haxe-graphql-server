package tests;

import php.Session;
import sys.io.File;
import haxe.Json;
import graphql.GraphQLError;
import graphql.GraphQLObject;
import graphql.GraphQLServer;
using Math;

class Manual {
    static function main() {
        var base_object = new ManualTest();
        var server = new GraphQLServer(base_object);
        server.run();
    }
}

@:typeName("Query")
class ManualTest implements GraphQLObject {
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
    @:validateResult( !result.contains(0), 'The result contains a 0 (${Std.string(result)})', "invalid_response")
    public function randomInts(n : Int = 10, min : Int = 1, max : Int  = 10) : Null<Array<Int>> {
        return [for(i in 0...n) (Math.random() * (max - min + 1)).floor() + min];
    }

    public function person(name:String = "Me") : ManualPerson {
        return new ManualPerson(name);
    }
}

@:typeName("Person")
class ManualPerson implements GraphQLObject {
    var _name : String;
    public function new (name:String) {
        _name = name;
    }

    @:validate(name != obj._name, 'Both names are the same ($name), and that is arbitrarily disallowed')
    public function greet(name : String = 'Sir') : String {
        return 'Hello, $name, my name is $_name';
    }
}