package graphql;

import graphql.externs.ClientAware;
import haxe.Exception;

@:keep class GraphQLError extends Exception implements ClientAware {
    var category:String;
    var clientSafe:Bool;

    public function new(message:String, category = "generic", clientSafe = true) {
        super(message);
        this.category = category;
        this.clientSafe = clientSafe;
    }

    function isClientSafe() {
        return clientSafe;
    }

    function getCategory() {
        return category;
    }
}
