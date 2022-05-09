package graphql.macro;
import haxe.macro.Context;

class Util {
    public static macro function requireVendor() {
        var vendor : String = switch [haxe.macro.Context.defined("vendor"), Context.definedValue("vendor")] {
            case [true, "0" | "false"]: return macro {};
            case [true, "1" | "true"]: "vendor/autoload.php";
            case [true, _]: Context.definedValue("vendor");
            case [false, _]: "vendor/autoload.php";
        }
        debug('Requiring $vendor');
        return macro php.Global.require_once($v{vendor});
    }

    #if macro
    /**
		If `graphql-verbose` flag is set, prints the provided message at build-time
	**/
	public static function debug(message:String) : Void {
		if(Context.defined("graphql-verbose")) {
			Sys.println('${Date.now()}> [graphql] $message');
		}
	}
    #end
}