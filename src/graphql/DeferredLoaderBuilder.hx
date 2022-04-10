package graphql;

import haxe.macro.Expr.Field;
import haxe.macro.Context;

class DeferredLoaderBuilder {
    public static macro function build() : Array<Field> {        
		var fields = Context.getBuildFields();
		var tmp_class = macro class {
            static var keys:Array<Dynamic> = [];
            static var values : Map<Dynamic,Dynamic>;
            static var loaded = false;

            static function add(key:Dynamic) {
                if(!keys.contains(key)) {
                    keys.push(key);
                }
            }
            static function loadOnce() {
                if(!loaded) {
                    load();
                    loaded = true;
                }
            }
            public static function get(id:Dynamic) {
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