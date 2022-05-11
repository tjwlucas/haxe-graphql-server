package graphql.externs.js;

@:jsRequire("domain")
extern class Domain {
    public static function create() : Domain;
    public function add(item:Any) : Domain;
    public function run(fn:Void -> Any) : Domain;
    var loaders : Map<String, graphql.externs.js.DataLoader<Any, Any>>;
    var requestValues : Map<String, Any>;
}