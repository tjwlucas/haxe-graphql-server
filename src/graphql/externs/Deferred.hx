package graphql.externs;

@:native('GraphQL\\Deferred')
extern class Deferred<T> {
    public function new(fn:Void->T);
}