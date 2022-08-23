package tests;

import graphql.GraphQLServer;
import tests.manual.ManualTestObject;
import graphql.Util;

class Manual {
    static function main() {
        var base_object = new ManualTestObject();
        var server = new GraphQLServer(base_object);
        server.run();
    }

    static function __init__() {
        Util.phpCompat();
    }
}
