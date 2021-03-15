package graphql;

import graphql.externs.ExecutionResult;
import php.Exception;
import php.NativeArray;
import graphql.externs.GraphQL;
import haxe.Json;
import sys.io.File;
import graphql.externs.Schema;
using php.Lib;

class GraphQLServer {
    var query : GraphQLObject;
    var mutation : Null<GraphQLObject>;
    var context : Null<Dynamic>;
    var root : Dynamic;
    public function new(base : GraphQLObject, ?context:Dynamic) {
        this.query = base;
        this.context = context;
        this.root = base;
    }

    public function executeQuery(query_string:String, ?variables : NativeArray) {
        if(variables == null) {
            variables = [].toPhpArray();
        }
		var schema = new Schema({
            query: query.gql.type,
            mutation: query.gql.mutation_type
        }.associativeArrayOfObject());
        
        return GraphQL.executeQuery(schema, query_string, root, this.context, variables);
    }

    public function run() {
        try {
            var query_string : String;
            var variables : Dynamic;
            try{
                var raw_input = File.getContent('php://input');
                var input = Json.parse(raw_input);
                query_string = input.query;
                variables = Lib.associativeArrayOfObject( input.variables != null ? input.variables : {} );
            } catch (e : php.Exception) {
                throw new Exception("No query provided");
            }
            var result = executeQuery(query_string, variables);
            Sys.print(Json.stringify(result.toArray()));
        } catch (e : php.Exception) {
            var result = {
                errors: {
                    message: e.getMessage()
                }
            };
            Sys.print(Json.stringify(result));
        }
    }

	static function __init__() {
		php.Global.require_once('vendor/autoload.php');
	}
}