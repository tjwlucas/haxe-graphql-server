package tests.cases;

import graphql.GraphQLObject;
import graphql.GraphQLObjectInterface;
import graphql.GraphQLServer;

class Manual {
    static function main() {
        var base_object = new ManualTest();
        var server = new GraphQLServer(base_object);
        server.run();
    }

	static function __init__() {
		php.Global.require_once('vendor/autoload.php');
	}
}

@:typeName("Query")
class ManualTest extends GraphQLObject implements GraphQLObjectInterface {
    public function new() {}

    /**
        Will always return true
    **/
    public var loaded:Bool = true;

    public function greet(name : String = 'Sir') : String {
        return 'Hello, $name';
    }
}