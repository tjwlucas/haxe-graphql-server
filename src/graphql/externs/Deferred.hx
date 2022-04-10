package graphql.externs;

@:native('GraphQL\\Deferred')
extern class Deferred {
    public function new(fn:Void->Dynamic);
}