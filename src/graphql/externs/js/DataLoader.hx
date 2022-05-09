package graphql.externs.js;

@:jsRequire("dataloader")
extern class DataLoader<K,V> {
    public function new(fn:Array<K>->js.lib.Promise<Array<V>>);
    public function load(id:K) : js.lib.Promise<V>;
}