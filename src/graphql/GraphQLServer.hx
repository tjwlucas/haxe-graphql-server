package graphql;

import graphql.externs.ExecutionResult;
import graphql.externs.SchemaPrinter;
import graphql.externs.GraphQL;
import haxe.Json;
import graphql.externs.Schema;

#if php
import sys.io.File;
import php.Global;
import php.Exception;
#end
using graphql.Util;
import graphql.externs.NativeArray;

/**
    Base class to build a GraphQL server to make use of the auto-generated Type objects.
**/
class GraphQLServer {
    var query : GraphQLObject;
    var mutation : Null<GraphQLObject>;
    var context : Null<Any>;
    var root : Any;
    var schema : Schema;

    public function new(base : GraphQLObject, ?context:Any) {
        this.query = base;
        this.context = context;
        this.root = base;
        this.schema = new Schema({
            query: query.gql.type,
            mutation: query.gql.mutationType
        }.associativeArrayOfObject());
    }

    /**
        Returns string representation of the constructed schema in `gql`, e.g.

        ```
        type Query {
            me: User
        }

        type User {
            id: ID
            name: String
        }
        ```
    **/
    @:keep public function readSchema()  : String {
        return SchemaPrinter.doPrint(schema);
    }

    /**
        Executes a query against the constructed schema and returns the results.

        @param queryString GraphQL query to execute
        @param variables Keyed array (In PHP) or object (In JS) of variables to pass in to the query.
        @param operationName Operation name for the query
    **/
    @:keep public function executeQuery(queryString:String, ?variables : NativeArray, ?operationName:String) : ExecutionResult {
        if (variables == null) {
            variables = [].toNativeArray();
        }

        return GraphQL.executeQuery(schema, queryString, root, this.context, variables, operationName);
    }

    /**
        Take raw input (from the request body), run it through the graphql server, and print the output.
        Expects a JSON in the body in the form `{"query": "...", "variables": {}, "operationName": ""}`
    **/
    public function run() : Void {
        #if php
        Global.header("Content-Type: application/json; charset=utf-8");
        try {
            var query_string : String;
            var variables : NativeArray;
            var operationName : String;
            try{
                var raw_input = File.getContent("php://input");
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
        #elseif (js && nodejs)
        var app = new  graphql.externs.js.Express();
        app.use((req, res, next) -> {
            var reqd = graphql.externs.js.Domain.create();
            reqd.loaders = [];
            reqd.requestValues = [];
            reqd.run(next);
        });
        app.use("/", new graphql.externs.js.GraphqlHTTP({
            schema: this.schema,
            rootValue: this.root,
            graphiql: true
        }));
        var portString = Sys.args()[0];
        var port = Std.parseInt(portString);
        @SuppressWarnings("checkstyle:MagicNumber")
        port = port != null ? port : 4000;
        app.listen(port);
        Sys.println('Running server on port $port');
        #else
        throw "Not implemented for anything except PHP & JS";
        #end
    }

    static function __init__() : Void {
        #if php
        graphql.macro.Util.requireVendor();
        #end
    }
}