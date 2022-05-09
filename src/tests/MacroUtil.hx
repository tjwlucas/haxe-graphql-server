package tests;

import sys.io.File;

class MacroUtil {
    public static macro function fileInclude(path:String) : ExprOf<String> {
        var schemaString = File.getContent(path);
        return macro $v{schemaString};
    }
}