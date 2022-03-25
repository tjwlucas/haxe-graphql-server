package graphql;
import graphql.externs.NativeArray;

class Util {
	public static inline function hashOfAssociativeArray(arr:Dynamic) : Map<String, Dynamic> {
		#if php
			return php.Lib.hashOfAssociativeArray(arr);
		#else
			return arr;
		#end
	}

	public static inline function associativeArrayOfObject(obj:Dynamic) {
		#if php
			return php.Lib.associativeArrayOfObject(obj);
		#else
			return obj;
		#end
	}

    public static inline function associativeArrayOfHash(hash:Map<String, Dynamic>) {
		#if php
            return php.Lib.associativeArrayOfHash(hash);
        #else
            return hash;
        #end
    }

	public static inline function toPhpArray(arr:Array<Dynamic>) : NativeArray {
		#if php
			return php.Lib.toPhpArray(arr);
		#else
			return arr;
		#end
	}
}