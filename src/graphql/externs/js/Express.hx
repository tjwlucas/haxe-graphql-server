package graphql.externs.js;

@:jsRequire('express')
extern class Express {
    @:selfCall public function new();
    public function use(path:String, httpObject: GraphqlHTTP) : Express;
    public function listen(port:Int) : Express;
}