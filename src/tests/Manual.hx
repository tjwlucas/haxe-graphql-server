package tests;

import sys.io.File;
import haxe.Json;
import graphql.GraphQLError;
import graphql.GraphQLObject;
import graphql.GraphQLServer;
import graphql.DeferredLoader;
using Math;

class Manual {
    static function main() {
        var base_object = new ManualTest();
        var server = new GraphQLServer(base_object);
        server.run();
    }

	static function __init__() {
        #if php
		// PHP 8.1 compatibility workaround https://github.com/HaxeFoundation/haxe/issues/10502
		untyped if (version_compare(PHP_VERSION, "8.1.0", ">=")) error_reporting(error_reporting() & ~E_DEPRECATED);
        #end
	}
}

@:typeName("Query")
class ManualTest implements GraphQLObject {
    public function new() {}

    /**
        Will always return true
    **/
    public var loaded:Bool = true;

    public function platform() : String {
        #if php return "PHP";
        #elseif js return "Javascript";
        #end
    }

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

    @:deferred(NestedDeferredLoader)
    public function getNested(id:Int = 0) : NestedDeferredTestObject;
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

class NestedDeferredTestObject implements GraphQLObject {
    public var n : Int;

    public function new(n:Int) {
        this.n = n ;
    }

    @:deferred(NestedDeferredLoader, obj.n + 1)
    public function getNext() : NestedDeferredTestObject;

    @:deferred(NestedDeferredLoader, obj.n - 1)
    public function getPrev() : NestedDeferredTestObject;
}

class NestedDeferredLoader extends DeferredLoader {
    public static var runBatches = [];
    static function load(keys:Array<Int>) : Map<Int, NestedDeferredTestObject> {
        var results : Map<Int, NestedDeferredTestObject> = [];
        runBatches.push(keys);
        for(key in keys) {
            results[key] = new NestedDeferredTestObject(key);
        }
        return results;
    }
}