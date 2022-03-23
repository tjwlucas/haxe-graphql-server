package graphql.macro;
import haxe.macro.Context;

class Util {
    public static macro function requireVendor() {
        var vendor : String = "vendor/autoload.php";

        var definedValue = Context.definedValue("vendor");
        
        if(haxe.macro.Context.defined("vendor")) {            
            if(["0", "false"].contains(definedValue)) {
                return macro {};
            } else if (!["1", "true"].contains(definedValue)) {
                vendor = definedValue;
            }
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