package graphql;

using graphql.Util;
import graphql.externs.NativeArray;

@:structInit
class GraphQLField {
    public var name: String;
    public var type: Dynamic;
    public var description: Null<String>;
    public var deprecationReason: Null<String>;
    public var args : NativeArray;

    public var resolve : Null<Dynamic>;
    public function toArray() {
        return graphql.Util.associativeArrayOfObject(this);
    }
}