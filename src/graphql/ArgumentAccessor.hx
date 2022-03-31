package graphql;

import graphql.externs.NativeArray;

abstract ArgumentAccessor(NativeArray) from NativeArray to NativeArray {
    @:op(a.b) public inline function fieldRead(name:String) {
        return arrayRead(name);
    }

  @:op([]) public inline function arrayRead(key:String) : Dynamic {    
      return this[key];
  }
}