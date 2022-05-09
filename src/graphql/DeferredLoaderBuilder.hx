package graphql;

import haxe.macro.Expr.Error;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Context;
using graphql.macro.Util;

class DeferredLoaderBuilder {
    public static macro function build() : Array<Field> {        
		var fields = Context.getBuildFields();
        var cls = Context.getLocalClass().get();
        var keyType : ComplexType;
        var returnType : ComplexType;
        var hasLoad = false;
        for(f in fields) {
            if(f.name == "load") {
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
        var temporaryClass = switch (Util.getTarget()) {
            case Php: macro class {
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
                        var newValues = load(keys);
                        for(k => v in newValues) {
                            values[k] = v;
                        }
                        keys = [];
                        runCount++;
                    }
                    return values[key];
                }
            }
            case Javascript: macro class {
                static var runCount = 0;
                private static var static_loader : graphql.externs.js.DataLoader<$keyType,$returnType>;

                private static var _loader(get, set) : graphql.externs.js.DataLoader<$keyType,$returnType>;
                public static function get__loader() {
                    var loaders : Map<String, Dynamic>;
                    if(graphql.externs.js.Process.domain == null) {
                        loaders = [
                            $v{cls.name} => static_loader
                        ];
                    } else {
                        loaders = graphql.externs.js.Process.domain.loaders;
                    }
                    return loaders[ $v{cls.name} ];
                }
                public static function set__loader(new_value: graphql.externs.js.DataLoader<$keyType,$returnType>) {
                    if(graphql.externs.js.Process.domain == null) {
                        static_loader = new_value;
                        return static_loader;
                    } else {
                        var loaders : Map<String, Dynamic>;
                        loaders = graphql.externs.js.Process.domain.loaders;
                        loaders[ $v{cls.name} ] = new_value;
                        return loaders[ $v{cls.name} ];
                    }
                }

                public static var loader(get, never) : graphql.externs.js.DataLoader<$keyType,$returnType>;
                static public function get_loader() {
                    if(_loader == null) {
                        _loader = new graphql.externs.js.DataLoader<$keyType,$returnType>((keys:Array<$keyType>) -> {
                            return new js.lib.Promise((resolve, reject) -> {
                                runCount++;
                                var values = load(keys);
                                resolve(keys.map(k -> values[k]));
                            });
                        });
                    }
                    return _loader;
                }
            }
        }

		temporaryClass.addFieldsFromClass(fields);
		return fields;
    }

    @SuppressWarnings("checkstyle:MultipleStringLiterals")  // "Map" in switch statement must be a literal, variables are interpreted as capture
    public static function getLoaderValueTypes(f:Field) {
        return switch (f.kind) {
            case(FFun({ret: TPath({name: "Map", params: [TPType(a), TPType(b)]})})): {
                key: a,
                ret: b
            }
            case (FFun({ret: TPath({name: "Map", params: [TPType(_) , _]})})): throw new Error("Invalid loader return type", f.pos);
            case (FFun({ret: TPath({name: "Map", params: [_, TPType(_)]})})): throw new Error("Bad key type", f.pos);
            case (FFun({ret: TPath({name: "Map", params: [_ , _]})})): throw new Error("Bad key and loader return types", f.pos);
            default: throw new Error("Load property must be a function returning a Map", f.pos);
        }
    }
}