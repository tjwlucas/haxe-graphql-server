package graphql.externs;


#if php @:native("GraphQL\\Error\\Error") #end
#if js @:jsRequire("graphql", "GraphQLError") #end
extern class Error #if php extends php.Exception #end {
    static var CATEGORY_GRAPHQL : String;
    static var CATEGORY_INTERNAL : String;
    function getLocations() : Array<SourceLocation>;
    function getPath() : Array<Dynamic>;

    #if php
	    public function isClientSafe() : Bool;
	    public function getCategory() : String;
    #end

    #if js
        var message : String;
        function toString() : String;
        public inline function getMessage() : String {
            // var formatted = GraphQLErrorFormatter.formatError(this);
            // trace(formatted);
            return this.message;
        }
    #end
}

#if js
@:jsRequire("graphql")
extern class GraphQLErrorFormatter {
    static function formatError(?error: Error) : GraphQLFormattedError;
}
@:jsRequire("graphql", "GraphQLFormattedError")
extern class GraphQLFormattedError {
    var message : String;
}
#end

@:native("GraphQL\\Language\\SourceLocation")
extern class SourceLocation {}