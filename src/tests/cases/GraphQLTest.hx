package tests.cases;

import graphql.externs.GraphQL;
import graphql.externs.Schema;
import graphql.TypeObjectDefinition;
import utest.Assert;
using php.Lib;
import graphql.GraphQLObject;

@:typeName("Query")
class GraphQLInstanceTest extends GraphQLObject {
    public function new(){}
    /**
        String field comment
    **/
    public var string_field:String = 'This is an instance value';
    /**
        Object field comment
    **/
    public var object_field:OtherObject = new OtherObject();

    public var nested_int : Array<Array<Int>> = [[1],[5,6]];
}

class OtherObject extends GraphQLObject {
    public function new(){}
    /**
        String field comment
    **/
    public var string_field:String = 'This is a value on the sub-object';
}

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
                    nested_int
                    object_field {
                        string_field
                    }
                }',
                new GraphQLInstanceTest()
            );
            result.errors == [].toPhpArray();
            Assert.notNull(result.data);
            if(result.data != null) {
                var data : Map<String, Dynamic> = result.data.hashOfAssociativeArray();

                var keys = [for(k in data.keys()) k];
                var expected_keys = ['string_field', 'renamed', 'nested_int', 'object_field'];
                Assert.same(keys,expected_keys,null,'Key list mismatch. Got: $keys, expected: $expected_keys');

                data['string_field'] ==  'This is an instance value';
                data['renamed'] == result.data['string_field'];
                data['nested_int'] == [
                    [1].toPhpArray(),
                    [5,6].toPhpArray()
                ].toPhpArray();
                Assert.notNull(data['object_field'], 'object_field is null');
                if(data['object_field'] != null) {
                    var subobject = Lib.hashOfAssociativeArray( data['object_field'] );
                    // Use same() assertion here instead of equality since haxe arrays are underlying objects which will be different instances
                    var keys = [for(k in subobject.keys()) k];
                    var expected_keys = ['string_field'];
                    Assert.same(keys,expected_keys,null,'Key list mismatch. Got: $keys, expected: $expected_keys');
                    subobject['string_field'] == 'This is a value on the sub-object';
                }
            }
        }
}

