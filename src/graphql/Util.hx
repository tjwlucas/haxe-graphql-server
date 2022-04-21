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
		#elseif js
			var obj : Dynamic = {};
			for(k => v in hash) {
				Reflect.setField(obj, k, v);
			}
			return obj;
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

	public static inline function processArgs(arr:Array<NativeArray>) : NativeArray {
		#if js
		var argsObject : Dynamic = {};
		for(arg in arr) {
			Reflect.setField(argsObject, arg.name, arg);
		}
		return argsObject;
		#else
			return toPhpArray(arr);
		#end
	}
}