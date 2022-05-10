package graphql.externs;

@SuppressWarnings("checkstyle:Dynamic")
abstract NativeArray
#if php (php.NativeArray) from php.NativeArray to php.NativeArray
#else (Dynamic) from Dynamic to Dynamic #end {
    @:op([]) public function arrayRead(key:String) : Any {
        #if php
        return this[key];
        #else
        return Reflect.getProperty(this, key);
        #end
    }

    @:op([]) public function arrayReadInt(key:Int) : Any {
        return this[key];
    }

    @:op(a.b) public inline function fieldRead(name:String) : Any {
        return arrayRead(name);
    }

    #if php
    public inline function iterator() {
        return php.Global.array_values(this).iterator();
    }
    #end

    public static inline function toHaxeArray(arr:NativeArray) : Array<Any> {
        #if php
        return php.Lib.toHaxeArray(arr);
        #else
        return arr;
        #end
    }

    public var length(get, never) : Int;
    inline function get_length() : Int {
        return toHaxeArray(this).length;
    }
}