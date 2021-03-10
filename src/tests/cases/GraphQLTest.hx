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
            var result = GraphQL.executeQuery(
                schema,
                '{
                    string_field
                    renamed:string_field
                }',
                new GraphQLInstanceTest()
            );
            result.errors == [].toPhpArray();
            Assert.notNull(result.data);
            var expected_result : Map<String, Dynamic> = [
                'string_field' => 'This is an instance value',
                'renamed' => 'This is an instance value'
            ];
            result.data == expected_result.associativeArrayOfHash();
        }
}

