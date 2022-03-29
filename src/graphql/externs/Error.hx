package graphql.externs;


@:native('GraphQL\\Error\\Error')
extern class Error #if php extends php.Exception #end {
    static var CATEGORY_GRAPHQL : String;
    static var CATEGORY_INTERNAL : String;
    function getLocations() : Array<SourceLocation>;
    function getPath() : Array<Dynamic>;

	public function isClientSafe() : Bool;
	public function getCategory() : String;
    #if !php
        public function getMessage() : String;
    #end
}

@:native('GraphQL\\Language\\SourceLocation')
extern class SourceLocation {}