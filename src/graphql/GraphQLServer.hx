package graphql;

import php.NativeArray;
import graphql.externs.GraphQL;
import haxe.Json;
import sys.io.File;
import graphql.externs.Schema;
using php.Lib;

class GraphQLServer {
    var query : GraphQLObjectInterface;
    var mutation : Null<GraphQLObjectInterface>;
    var context : Null<Dynamic>;
    var root : Dynamic;
    public function new(base : GraphQLObjectInterface, ?mutation:GraphQLObjectInterface, ?context:Dynamic) {
        this.query = base;
        this.mutation = mutation;
        this.context = context;
        this.root = base;
    }

    public function executeQuery(query_string:String, variables : NativeArray) {
		var schema = new Schema({
            query: query.gql.type,
            mutation: mutation != null ? mutation.gql.type : null
        }.associativeArrayOfObject());
        
        return GraphQL.executeQuery(schema, query_string, root, this.context, variables);
    }

    public function run() {
        var raw_input = File.getContent('php://input');
        var input = Json.parse(raw_input);
        var query_string = input.query;
        var variables = Lib.associativeArrayOfObject( input.variables != null ? input.variables : {} );

        var result = executeQuery(query_string, variables);

        Sys.print(Json.stringify(result));
    }
}