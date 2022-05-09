package tests.cases;

import sys.io.File;
import graphql.externs.Error;
import graphql.GraphQLError;
import utest.Assert;
import graphql.GraphQLServer;
import graphql.DeferredLoader;
import graphql.GraphQLObject;
import utest.Test;
import graphql.externs.Deferred;
using graphql.Util;
import graphql.externs.NativeArray;

#if php
using php.Lib;
import php.NativeArray;
#end

#if js
@:build(hxasync.AsyncMacro.build())
#end
class DeferredTest extends Test {
    function setup() {}

    @async function specDeferredResolver(async:utest.Async) {
        var base = new DeferredTestObject();
        var server = new GraphQLServer(base);

        @:privateAccess DeferredTestLoader.runCount == 0;
        #if php
        @:privateAccess Assert.same(
            [],
            DeferredTestLoader.keys
        );
        @:privateAccess Assert.same(
            ([] : Map<Int, String>),
            DeferredTestLoader.values
        );
        #end

        var result = @await server.executeQuery("query($id:Int!, $id2:Int!, $id3: Int!, $idString:String!, $idStringError:String!){
            getValue(id: $id)
            another:getValue(id:$id2)
            getStaticValue(id:$idString)
            staticError:getStaticValue(id:$idStringError)
            getSubObject {
                getValue(id: $id)
                value2:getValue(id: $id3)
                objectValue:getObjectValue
            }
            manualDeferredObject
        }", {
            id: 42,
            id2: 367,
            id3: 13,
            idString: "valid",
            idStringError: "alsoValid"
        }.associativeArrayOfObject());

        result.data['getValue'] == "This is the value for id 42, loaded";
        result.data['another'] == "This is the value for id 367, loaded";
        result.data['manualDeferredObject'] == "Some string";
        var subObject : NativeArray = result.data['getSubObject'];
        subObject['getValue'] == "This is the value for id 42, loaded";
        subObject['value2'] == "This is the value for id 13, loaded";
        subObject['objectValue'] == "This is the value for id 13, loaded";
        Assert.equals(42, result.data['getStaticValue']);
        @:privateAccess DeferredTestLoader.runCount == 1;
        #if php
        @:privateAccess Assert.same(
            [],
            DeferredTestLoader.keys
            );
            @:privateAccess Assert.notNull(DeferredTestLoader.values);
            @:privateAccess Assert.same([
                42 => "This is the value for id 42, loaded",
                367 => "This is the value for id 367, loaded",
                13 => "This is the value for id 13, loaded",
            ], DeferredTestLoader.values);
        #end

        Assert.notNull(result.errors);
        var errors = result.errors.toHaxeArray();
        errors.length == 1;
        var error : Error = errors[0];
        @:privateAccess error.getMessage() == 'Validation failed';
        #if php
        error.getCategory() == 'validation';
        error.isClientSafe() == true;
        #end
        async.done();
    }

    @async function specNestedDeferredResolver(async:utest.Async) {
        var base = new DeferredTestObject();
        var server = new GraphQLServer(base);
        @await server.executeQuery("{
            top1: getNested(id: 3) {
                n
                getNext {
                    n
                }
            }
            top2: getNested {
                n
                getNext {
                    n
                    getNext {
                  n
                  getNext {
                    n
                    getNext {
                        n
                        getPrev {
                            n
                            getPrev {
                                n
                            }
                        }
                    }
                }
                }
                again: getNext {
                    n
                }
              }
            }
          }
          ");
        Assert.same([
            [3,0],
            [4,1],
            [2]
        ], NestedDeferredLoader.runBatches);
        async.done();
    }
}

class DeferredTestObject implements GraphQLObject {
    public function new() {}
    
    @:deferred(tests.cases.DeferredTestLoader)
    public function getValue(id:Int) : String;
    
    @:deferred(tests.cases.DeferredStaticTestLoader)
    @:validateResult(result != 98)
    public function getStaticValue(id:String) : Null<Int>;

    public function getSubObject() : DeferredTestSubObject {
        return new DeferredTestSubObject();
    }

    @:deferred(NestedDeferredLoader)
    public function getNested(id:Int = 0) : NestedDeferredTestObject;

    #if php
    public function manualDeferredObject() : graphql.externs.Deferred<String> {
        return new graphql.externs.Deferred(() -> "Some string");
    }
    #elseif js
    public function manualDeferredObject() : js.lib.Promise<String> {
        return new js.lib.Promise((resolve, reject) -> resolve("Some string"));
    }
    #end
}

class DeferredTestSubObject implements GraphQLObject {
    public function new() {}

    var objectProperty = 13;

    @:deferred(tests.cases.DeferredTestLoader)
    public function getValue(id:Int) : String;

    @:deferred(tests.cases.DeferredTestLoader, obj.objectProperty)
    public function getObjectValue() : String;
}

class DeferredTestLoader extends DeferredLoader {
    static function load(keys:Array<Int>) : Map<Int, String> {
        #if php
        if(runCount > 0) {
            throw "Load function should not be called more than once";
        }
        #end
        var results : Map<Int, String> = [];
        for(key in keys) {
            results[key] = 'This is the value for id $key, loaded';
        }
        return results;
    }
}


/**
    Trivial example with different types
**/
class DeferredStaticTestLoader extends DeferredLoader {
    static function load(keys:Array<String>) : Map<String, Int> {
        return [
            "valid" => 42,
            "alsoValid" => 98
        ];
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