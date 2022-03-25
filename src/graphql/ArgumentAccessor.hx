package graphql;

import graphql.externs.NativeArray;

abstract ArgumentAccessor(NativeArray) from NativeArray to NativeArray {
    @:op(a.b) public inline function fieldRead(name:String) {
        return arrayRead(name);
    }

  @:op([]) public function arrayRead(key:String) : Dynamic {    
    // try {
      return this[key];
    // } catch (e:php.ErrorException) {
    //   return null;
    // }
  }
}