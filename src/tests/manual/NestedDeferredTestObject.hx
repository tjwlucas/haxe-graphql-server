package tests.manual;

import graphql.GraphQLObject;

class NestedDeferredTestObject implements GraphQLObject {
    public var n : Int;

    public function new(n:Int) {
        this.n = n;
    }

    @:deferred(NestedDeferredLoader, obj.n + 1)
    public function getNext() : NestedDeferredTestObject;

    @:deferred(NestedDeferredLoader, obj.n - 1)
    public function getPrev() : NestedDeferredTestObject;
}