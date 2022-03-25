package graphql;

import graphql.externs.ExecutionResult;
import graphql.externs.GraphQL;
import haxe.Json;
import sys.io.File;
import graphql.externs.Schema;

#if php 
    import php.Global;
    import php.Exception;
#end
using graphql.Util;
import graphql.externs.NativeArray;

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

    public function executeQuery(query_string:String, ?variables : NativeArray, ?operationName:String) {
        if(variables == null) {
            variables = [].toPhpArray();
        }
		var schema = new Schema({
            query: query.gql.type,
            mutation: query.gql.mutation_type
        }.associativeArrayOfObject());
        
        return GraphQL.executeQuery(schema, query_string, root, this.context, variables, operationName);
    }

    /**
        Take raw input (from `php://input`), run it through the graphql server, and print the output.
        Expects a JSON in the body in form `{"query": "...", "variables": {}, "operationName": ""}`
    **/
    public function run() {
        #if php
        Global.header("Content-Type: application/json; charset=utf-8");
        try {
            var query_string : String;
            var variables : NativeArray;
            var operationName : String;
            try{
                var raw_input = File.getContent('php://input');
                var input = Json.parse(raw_input);
                query_string = input.query;
                variables = Util.associativeArrayOfObject( input.variables != null ? input.variables : {} );
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
        #else
            trace("Not implemented for anything except PHP");
        #end
    }

	static function __init__() {
        #if php
            graphql.macro.Util.requireVendor();
        #end
	}
}