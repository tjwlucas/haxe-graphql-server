package graphql;

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
        for(f in fields) {
            if(f.name == 'load') {
                switch (f.kind) {
                    case(FFun({ret: ret})):
                        switch(ret) {
                            case TPath({name: 'Map', params: p}):
                                switch(p[0]) {
                                    case(TPType(t)):
                                        keyType = t;
                                    default: throw "Bad key type";
                                }
                                switch(p[1]) {
                                    case(TPType(t)):
                                        returnType = t;
                                    default: throw "Invalid loader return type";
                                }
                            default:
                                throw "Invalid function return type";
                        }
                    default: throw "Invalid load() function";
                }
            }
        }
		var tmp_class = macro class {
            static var keys:Array<$keyType> = [];
            static var values : Null<Map<$keyType,$returnType>> = null;
            static var loaded = false;

            static function add(key:$keyType) {
                if(!keys.contains(key)) {
                    keys.push(key);
                }
            }
            static function loadOnce() : Void {
                if(!loaded) {
                    values = load();
                    loaded = true;
                }
            }
            public static function get(id:$keyType) : graphql.externs.Deferred<$returnType> {
                add(id);
                return new graphql.externs.Deferred(() -> {
                    loadOnce();
                    return values[id];
                });
            }
        }
        
		for (field in tmp_class.fields) {
			fields.push(field);
		}
		return fields;
    }
}