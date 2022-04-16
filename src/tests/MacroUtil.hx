package tests;

import sys.io.File;

class MacroUtil {
    public macro static function fileInclude(path:String) : ExprOf<String> {
        var schemaString = File.getContent(path);
        return macro $v{schemaString};
    }
}