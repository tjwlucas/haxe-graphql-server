package graphql;

import php.NativeArray;

abstract NativeArrayAccessor(NativeArray) from NativeArray to NativeArray {
    @:op(a.b) public inline function fieldRead(name:String) {
        return this[name];
    }

  @:op([]) public function arrayRead(key:String) : Dynamic;
}