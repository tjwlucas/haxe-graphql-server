package tests.cases;

import php.NativeArray;
import graphql.externs.GraphQL;
import graphql.externs.Schema;
import graphql.TypeObjectDefinition;
import utest.Assert;
import tests.types.GraphQLInstanceTest;
using php.Lib;

class GraphQLTest extends utest.Test {
        function specGraphQLInstanceClass() {
            Assert.notNull(GraphQLInstanceTest.gql);
            Assert.notNull(GraphQLInstanceTest.gql.type);
        }

        function specQuerying() {
            var schema = new Schema({
                query: GraphQLInstanceTest.gql.type
            }.associativeArrayOfObject());
            var result : {
                errors: NativeArray,
                data: NativeArray
            } = GraphQL.executeQuery(
                schema,
                '{string_field}',
                new GraphQLInstanceTest()
            );
            result.errors == [].toPhpArray();
            Assert.notNull(result.data);
            result.data['string_field'] == 'This is an instance value';
        }
}

