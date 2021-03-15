package graphql.externs;


@:native('GraphQL\\Error\\Error')
extern class Error extends php.Exception {
    static var CATEGORY_GRAPHQL : String;
    static var CATEGORY_INTERNAL : String;
    function getLocations() : Array<SourceLocation>;
    function getPath() : Array<Dynamic>;
}

@:native('GraphQL\\Language\\SourceLocation')
extern class SourceLocation {}