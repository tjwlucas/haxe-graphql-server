package graphql.externs;

#if php @:native('GraphQL\\Deferred')
extern class Deferred<T> {
    public function new(fn:Void->T);
}
#end