package tests.cases;

import graphql.GraphQLServer;
import graphql.DeferredLoader;
import graphql.GraphQLObject;
import utest.Test;

using php.Lib;

class DeferredTest extends Test {
    function setup() {

    }

    function specDeferredResolver() {
        var base = new DeferredTestObject();
        var server = new GraphQLServer(base);
        var result = server.executeQuery("query($id:Int!, $id2:Int!){
            getValue(id: $id)
            another:getValue(id:$id2)
        }", {
            id: 42,
            id2: 367
        }.associativeArrayOfObject());


        result.data['getValue'] == "This is the value for id 42, loaded";
        result.data['another'] == "This is the value for id 367, loaded";
    }
}

class DeferredTestObject implements GraphQLObject {
    public function new() {}

    public function getValue(id:Int) : String {
        // TODO: Sort out typing (Add `Deffered<T>` type?)
        var value : Dynamic = DeferredTestLoader.get(id);
        return value;
    }
}

class DeferredTestLoader implements DeferredLoader {
    static function load() {
        if(loaded) {
            throw "Load function should not be called more than once";
        }
        var results : Map<Int, String> = [];
        for(key in DeferredTestLoader.keys) {
            results[key] = 'This is the value for id $key, loaded';
        }
        values = results;
    }
}