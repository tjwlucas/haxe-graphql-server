package graphql;

/**
    Primary interface to be implemented to generate a GraphQL Object.

    Any class that implements this interface will be auto built into a compatible GraphQL type with can be passed to `GraphQLServer`.

    e.g.

    ```
    @:structInit class Query implements GraphQLObject {
        var prefix : String;
        public function new(){}    
        public function echo(message:String) : Null<String> {
            return prefix + message;
        }
    }
    ```

    Is ready to be passed in to:

    ```
    class Main {
        static function main() {
            var queryObject : Query = {
                prefix: "You said: "
            };
            var server = new GraphQLServer(queryObject);
            server.run();
        }
    }
    ```
**/
@:autoBuild(graphql.TypeBuilder.build())
interface GraphQLObject {
    /**
        Object holding generated GraphQL schema and resolver definition for this class
    **/
    var gql(get, null) : graphql.TypeObjectDefinition;

    private function get_gql() : graphql.TypeObjectDefinition;
}
