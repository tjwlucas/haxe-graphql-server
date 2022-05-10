package graphql.externs;

#if php
abstract NativeArray(php.NativeArray) from php.NativeArray to php.NativeArray {
    @:op([]) public function arrayRead(key:String) : Dynamic {
        return this[key];
    }

    @:op([]) public function arrayReadInt(key:Int) : Dynamic {
        return this[key];
    }

    @:op(a.b) public inline function fieldRead(name:String) : Dynamic {
        return arrayRead(name);
    }

    public inline function iterator() {
        return php.Global.array_values(this).iterator();
    }

    public static inline function toHaxeArray(arr:php.NativeArray) : Array<Dynamic> {
        return php.Lib.toHaxeArray(arr);
    }

    public var length(get, never) : Int;
    inline function get_length() : Int {
        return toHaxeArray(this).length;
    }
}
#else
abstract NativeArray(Dynamic) from Dynamic to Dynamic {
    @:op([]) public function arrayRead(key:String) : Dynamic {
        return Reflect.getProperty(this, key);
    }

    @:op([]) public function arrayReadInt(key:Int) : Dynamic {
        return this[key];
    }

    @:op(a.b) public inline function fieldRead(name:String) : Dynamic {
        return arrayRead(name);
    }

    public function toHaxeArray() : Array<Dynamic> {
        return this;
    }
}
#end