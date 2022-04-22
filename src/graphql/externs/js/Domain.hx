package graphql.externs.js;

@:jsRequire('domain')
extern class Domain {
    public static function create() : Domain;
    public function add(item:Dynamic) : Domain;
    public function run(fn:Void->Dynamic) : Domain;
    var loaders : Map<String, graphql.externs.js.DataLoader<Dynamic, Dynamic>>;
    var requestValues : Map<String, Dynamic>;
}