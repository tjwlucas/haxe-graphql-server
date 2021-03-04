package graphql;

typedef GraphQLField = {
    name: String,
    type: Dynamic,
    ?comment: String,
    ?deprecationReason: String
}