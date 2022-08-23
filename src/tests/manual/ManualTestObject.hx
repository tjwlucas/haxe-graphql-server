package tests.manual;

import graphql.GraphQLObject;
using Math;

@:typeName("Query")
class ManualTestObject implements GraphQLObject {
    public function new() {}

    #if php
    static var _calledCount : Int = 0;
    #end

    public static function calledCount() : Int {
        #if js
        var requestValues = Process.domain.requestValues;
        if (!requestValues.exists("CALLED_COUNT")) {
            requestValues["CALLED_COUNT"] = 0;
        }
        return ++Process.domain.requestValues["CALLED_COUNT"];
        #end
        #if php
        return ++_calledCount;
        #end
    }

    /**
        Will always return true
    **/
    public var loaded:Bool = true;

    public function platform() : String {
        return graphql.macro.Util.getTargetMacro();
    }

    @:validationContext(var capName = (name:String).toUpperCase())
    @:validationContext(var disallowed = "me".toUpperCase())
    @:validate(capName != disallowed, 'You are not allowed to greet "$name"')
    public function greet(name : String = "Sir") : String {
        return 'Hello, $name';
    }

    @:validationContext(var nlimit = 1000)
    @:validate(n >= 0, 'n must be non-negative ($n given)')
    @:validate(n <= nlimit, 'n must be <= $nlimit ($n given)')
    @:validate(min <= max, 'min ($min) cannot be greater than max ($max)')
    @:validateResult( !result.contains(0), 'The result contains a 0 (${Std.string(result)})', "invalid_response")
    public function randomInts(n : Int = 10, min : Int = 1, max : Int  = 10) : Null<Array<Int>> {
        return [for (i in 0...n) (Math.random() * (max - min + 1)).floor() + min];
    }

    public function person(name:String = "Me") : ManualPerson {
        return new ManualPerson(name);
    }

    @:deferred(NestedDeferredLoader)
    public function getNested(id:Int = 0) : NestedDeferredTestObject;
}
