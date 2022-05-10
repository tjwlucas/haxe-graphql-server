package graphql;

import graphql.externs.NativeArray;

class Util {
    /**
        Transforms either a (PHP) associative array or a (JS) object into a native haxe String Map.

        @param arr Associative array (PHP), or Object
    **/
    @SuppressWarnings("checkstyle:Dynamic")
    public static inline function hashOfAssociativeArray(arr:Dynamic) : Map<String, Any> {
        #if php
        return php.Lib.hashOfAssociativeArray(arr);
        #else
        var returnMap : Map<String, Any> = [];
        for (key in Reflect.fields(arr)) {
            returnMap[key] = Reflect.field(arr, key);
        }
        return returnMap;
        #end
    }

    /**
        Transforms an object into a native haxe String Map.

        @param obj Object
    **/
    @SuppressWarnings("checkstyle:Dynamic")
    public static inline function associativeArrayOfObject(obj:Dynamic) {
        #if php
        return php.Lib.associativeArrayOfObject(obj);
        #else
        return obj;
        #end
    }

    /**
        Transforms a native haxe String Map into an associative array (PHP) or an object (JS)

        @param hash The haxe String Map
    **/
    public static inline function associativeArrayOfHash(hash:Map<String, Any>) {
        #if php
        var result = php.Lib.associativeArrayOfHash(hash);
        #elseif js
        var result : Any = {};
        for (k => v in hash) {
            Reflect.setField(result, k, v);
        }
        #else
        var result = hash;
        #end
        return result;
    }

    /**
        Converts a haxe array to a native array in PHP, otherwise, does nothing

        @param arr Haxe array
    **/
    public static inline function toNativeArray(arr:Array<Any>) : NativeArray {
        #if php
        return php.Lib.toPhpArray(arr);
        #else
        return arr;
        #end
    }

    /**
        In PHP target: Returns passed array of arguments as a native PHP array.

        For Javascript: The `graphql-js` expects an object with the argument field names as the keys,
        so this returns such an object

        @param arr Array of arguments
    **/
    public static inline function processArgs(arr:Array<NativeArray>) : NativeArray {
        #if js
        var argsObject : Any = {};
        for (arg in arr) {
            Reflect.setField(argsObject, arg.name, arg);
        }
        return argsObject;
        #else
        return toNativeArray(arr);
        #end
    }

    #if js
    /**
        Dummy function in JS, so that toHaxeArray calls can be ignored, rather than repeated conditinal compilation

        @param a An array, which will be returned
    **/
    public static inline function toHaxeArray(a:Array<Any>):Array<Any> {
        return a;
    }
    #end

    /**
        PHP 8.1 compatibility workaround https://github.com/HaxeFoundation/haxe/issues/10502
        
        (Will safely do nothing outside of PHP targets)
    **/
    public static inline function phpCompat() {
        #if php
        untyped if (version_compare(PHP_VERSION, "8.1.0", ">=")) error_reporting(error_reporting() & ~E_DEPRECATED);
        #end
    }
}