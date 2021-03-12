package graphql.externs;

import php.NativeArray;

@:native('GraphQL\\Executor\\ExecutionResult')
extern class ExecutionResult {
    public function toArray(?debug : Int) : NativeArray;
    public var errors : NativeArray;
    public var data : NativeArray;
}

enum abstract DebugFlag(Int) from Int to Int {
    public var NONE                        = 0;
    public var INCLUDE_DEBUG_MESSAGE       = 1;
    public var INCLUDE_TRACE               = 2;
    public var RETHROW_INTERNAL_EXCEPTIONS = 4;
    public var RETHROW_UNSAFE_EXCEPTIONS   = 8;
    public static inline function getDebugValue(flags: Array<DebugFlag>) : Int {
        var result = 0;
        for(f in flags) {
            result += f;
        }
        return result;
    }
}