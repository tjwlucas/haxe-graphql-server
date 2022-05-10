package graphql;

/**
    Abstract type to represent the GraphQL `ID` type
**/
abstract IDType(String) from String to String {
    @:from public static inline function fromInt(int:Int) : IDType {
        return Std.string(int);
    }

    @:to public inline function toInt() : Int {
        return Std.parseInt(this);
    }
}