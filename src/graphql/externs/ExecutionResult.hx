package graphql.externs;

#if php
@:native("GraphQL\\Executor\\ExecutionResult")
extern class ExecutionResult {
    public function toArray(?debug : Int) : NativeArray;
    @:optional public var errors : NativeArray;
    @:optional public var data : NativeArray;
}
#else
typedef ExecutionResult = {
    @:optional public var errors : Array<Error>;
    @:optional public var data : NativeArray;
}
#end

enum abstract DebugFlag(Int) from Int to Int {
    final NONE                        = 0;
    final INCLUDE_DEBUG_MESSAGE       = 1;
    final INCLUDE_TRACE               = 2;
    final RETHROW_INTERNAL_EXCEPTIONS = 4;
    final RETHROW_UNSAFE_EXCEPTIONS   = 8;
    public static inline function getDebugValue(flags: Array<DebugFlag>) : Int {
        var result = 0;
        for(f in flags) {
            result += f;
        }
        return result;
    }
}