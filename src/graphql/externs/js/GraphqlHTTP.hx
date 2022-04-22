package graphql.externs.js;

@:jsRequire('express-graphql', 'graphqlHTTP')
extern class GraphqlHTTP {
    @:selfCall public function new(options:{
        schema: Schema,
        rootValue: Dynamic,
        graphiql: Bool
    });
}