package tests.cases;

import utest.Assert;
import graphql.GraphQLServer;
import graphql.DeferredLoader;
import graphql.GraphQLObject;
import utest.Test;
import graphql.externs.Deferred;

using php.Lib;

class DeferredTest extends Test {
    function setup() {

    }

    function specDeferredResolver() {
        var base = new DeferredTestObject();
        var server = new GraphQLServer(base);

        @:privateAccess DeferredTestLoader.loaded == false;
        @:privateAccess Assert.same(
            [],
            DeferredTestLoader.keys
        );
        @:privateAccess Assert.isNull(DeferredTestLoader.values);

        var result = server.executeQuery("query($id:Int!, $id2:Int!){
            getValue(id: $id)
            another:getValue(id:$id2)
        }", {
            id: 42,
            id2: 367
        }.associativeArrayOfObject());

        result.data['getValue'] == "This is the value for id 42, loaded";
        result.data['another'] == "This is the value for id 367, loaded";

        @:privateAccess DeferredTestLoader.loaded == true;
        @:privateAccess Assert.same(
            [42, 367],
            DeferredTestLoader.keys
        );
        @:privateAccess Assert.notNull(DeferredTestLoader.values);
        @:privateAccess Assert.same([
            42 => "This is the value for id 42, loaded",
            367 => "This is the value for id 367, loaded"
        ], DeferredTestLoader.values);
    }
}

class DeferredTestObject implements GraphQLObject {
    public function new() {}

    public function getValue(id:Int) : Deferred<String> {
        return DeferredTestLoader.get(id);
    }
}

class DeferredTestLoader implements DeferredLoader {
    static function load() : Map<Int, String> {
        if(loaded) {
            throw "Load function should not be called more than once";
        }
        var results : Map<Int, String> = [];
        for(key in keys) {
            results[key] = 'This is the value for id $key, loaded';
        }
        return results;
    }
}