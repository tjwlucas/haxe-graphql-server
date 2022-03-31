package graphql;

import graphql.externs.SchemaPrinter;
import graphql.macro.Util;
import php.Global;
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
    var schema : Schema;

    public function new(base : GraphQLObject, ?context:Dynamic) {
        this.query = base;
        this.context = context;
        this.root = base;
        this.schema = new Schema({
            query: query.gql.type,
            mutation: query.gql.mutation_type
        }.associativeArrayOfObject());
    }

    public function readSchema()  : String {
        return SchemaPrinter.doPrint(schema);
    }

    public function executeQuery(query_string:String, ?variables : NativeArray, ?operationName:String) {
        if(variables == null) {
            variables = [].toPhpArray();
        }
        
        return GraphQL.executeQuery(schema, query_string, root, this.context, variables, operationName);
    }

    /**
        Take raw input (from `php://input`), run it through the graphql server, and print the output.
        Expects a JSON in the body in form `{"query": "...", "variables": {}, "operationName": ""}`
    **/
    public function run() {
        Global.header("Content-Type: application/json; charset=utf-8");
        try {
            var query_string : String;
            var variables : NativeArray;
            var operationName : String;
            try{
                var raw_input = File.getContent('php://input');
                var input = Json.parse(raw_input);
                query_string = input.query;
                variables = Lib.associativeArrayOfObject( input.variables != null ? input.variables : {} );
                operationName = input.operationName;
            } catch (e : php.Exception) {
                throw new Exception("No query provided");
            }
            var result = executeQuery(query_string, variables, operationName);
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
        Util.requireVendor();
	}
}