package graphql.externs;

#if php @:native('GraphQL\\Deferred')
#elseif js @:native('Promise')
#end
extern class Deferred<T> {
    public function new(fn:Void->T);
}