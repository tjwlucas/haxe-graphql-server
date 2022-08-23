package tests.manual;

import graphql.DeferredLoader;

class NestedDeferredLoader extends DeferredLoader {
    public static final runBatches : Array<Array<Int>> = [];
    static function load(keys:Array<Int>) : Map<Int, NestedDeferredTestObject> {
        var results : Map<Int, NestedDeferredTestObject> = [];
        runBatches.push(keys);
        for (key in keys) {
            results[key] = new NestedDeferredTestObject(key);
        }
        return results;
    }
}