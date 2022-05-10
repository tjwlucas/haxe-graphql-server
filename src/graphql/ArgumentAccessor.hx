package graphql;

import graphql.externs.NativeArray;

abstract ArgumentAccessor(NativeArray) from NativeArray to NativeArray {
    @:op(a.b) public inline function fieldRead(name:String) : Any {
        return arrayRead(name);
    }

    @:op([]) public inline function arrayRead(key:String) : Any {
        return this[key];
    }
}