package graphql;

#if php
    using php.Lib;
#end

@:structInit
class GraphQLField {
    public var name: String;
    public var type: Dynamic;
    public var comment: Null<String>;
    public var deprecationReason: Null<String>;

    #if php
        public function toArray() {
            return php.Lib.associativeArrayOfObject(this);
        }
    #end
}