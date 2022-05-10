package graphql.macro;

import haxe.macro.Expr.Field;
import haxe.macro.Expr.TypeDefinition;
import haxe.macro.Context;

class Util {
    static inline final AUTOLOAD_DEFAULT_PATH = "vendor/autoload.php";

    static inline final VENDOR = "vendor";

    /**
        Add autoload, based on compiler configuration using the `-D vendor` flag
    **/
    public static macro function requireVendor() {
        var vendor : String = switch [haxe.macro.Context.defined(VENDOR), Context.definedValue(VENDOR)] {
            case [true, "0" | "false"]: return macro {};
            case [true, "1" | "true"]: AUTOLOAD_DEFAULT_PATH;
            case [true, value]: value;
            case [false, _]: AUTOLOAD_DEFAULT_PATH;
        }
        debug('Requiring $vendor');
        return macro php.Global.require_once($v{vendor});
    }

    /**
        Returns current compiler target
    **/
    public static macro function getTargetMacro() : ExprOf<SupportedTarget> {
        return macro $v{ getTarget() };
    }

    #if macro
    /**
		If `graphql-verbose` flag is set, prints the provided message at build-time

        @param message The message to output if debug is on
	**/
    public static function debug(message:String) : Void {
        if (Context.defined("graphql-verbose")) {
            Sys.println('${Date.now()}> [graphql] $message');
        }
    }

    /**
        Push all fields from provided class definition to field list

        @param cls Class type definition
        @param fields Array of fields. This array will be modified, as well as returned.
    **/
    public static inline function addFieldsFromClass(cls : TypeDefinition, fields : Array<Field>) {
        for (field in cls.fields) {
            fields.push(field);
        }
        return fields;
    }

    /**
        Returns current compiler target
    **/
    public static function getTarget() : SupportedTarget {
        if (Context.defined("php")) {
            return Php;
        } else if (Context.defined("js")) {
            return Javascript;
        } else {
            throw "Not a supported target";
        }
    }
    #end
}