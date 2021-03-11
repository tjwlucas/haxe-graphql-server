package graphql;
#if php
    using php.Lib;
#end

@:structInit
class GraphQLField {
    public var name: String;
    public var type: Dynamic;
    public var description: Null<String>;
    public var deprecationReason: Null<String>;
    public var args : #if php php.NativeArray #else Dynamic #end;

    public var resolve : Null<Dynamic>;
    #if php
        public function toArray() {
            return php.Lib.associativeArrayOfObject(this);
        }
    #end
}