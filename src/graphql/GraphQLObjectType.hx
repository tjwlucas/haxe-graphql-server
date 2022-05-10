package graphql;

/**
    Type of GraphQL object (i.e. Query or Mutation). Used to determine which type of object is being built. 
    
    The same underlying class can generate a (different) Type Object for each query type.
**/
enum GraphQLObjectType {
    Query;
    Mutation;
}