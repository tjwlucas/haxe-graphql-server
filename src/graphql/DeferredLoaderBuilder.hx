package graphql;

import haxe.macro.Expr.Error;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Tools.TTypeTools;
import haxe.macro.TypeTools;
import haxe.macro.Expr.Field;
import haxe.macro.Context;

class DeferredLoaderBuilder {
    public static macro function build() : Array<Field> {        
		var fields = Context.getBuildFields();
        var keyType : ComplexType;
        var returnType : ComplexType;
        var hasLoad = false;
        for(f in fields) {
            if(f.name == 'load') {
                hasLoad = true;
                if(!f.access.contains(AStatic)) {
                    throw new Error("Load function must be static", f.pos);
                }
                var types = getLoaderValueTypes(f);
                keyType = types.key;
                returnType = types.ret;
            }
        }
        if(!hasLoad) {
            throw new Error("DeferredLoader class must declare a load() function", Context.currentPos());
        }
		var tmp_class = macro class {
            static var keys:Array<$keyType> = [];
            public static var values : Map<$keyType,$returnType> = [];
            static var runCount = 0;

            public static function add(key:$keyType) {
                if(!keys.contains(key)) {
                    keys.push(key);
                }
            }

            public static function getValue(key:$keyType) : $returnType {
                var loadedKeys = [for (k in values.keys()) k];
                if(!loadedKeys.contains(key)) {
                    var newValues = load();
                    for(k => v in newValues) {
                        values[k] = v;
                    }
                    keys = [];
                    runCount++;
                }
                return values[key];
            }
        }
        
		for (field in tmp_class.fields) {
			fields.push(field);
		}
		return fields;
    }

    public static function getLoaderValueTypes(f:Field) {
        var keyType : ComplexType;
        var returnType : ComplexType;
        switch (f.kind) {
            case(FFun({ret: ret})):
                switch(ret) {
                    case TPath({name: 'Map', params: p}):
                        switch(p[0]) {
                            case(TPType(t)):
                                keyType = t;
                            default: throw new Error("Bad key type", f.pos);
                        }
                        switch(p[1]) {
                            case(TPType(t)):
                                returnType = t;
                            default: throw new Error("Invalid loader return type", f.pos);
                        }
                    default:
                        throw new Error("Load function must return a Map", f.pos);
                }
            default: throw new Error("load property must be a function", f.pos);
        }
        return {
            key: keyType,
            ret: returnType
        };
    }
}