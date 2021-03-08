<?php

use GraphQL\GraphQL;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Schema;
use graphql\TypeObjectDefinition;
use PHPUnit\Framework\TestCase;
use tests\cases\GraphQLInstanceTest;

class GraphQLTest extends TestCase
{
    function testGraphQLInstanceExists()
    {
        $this->assertClassHasAttribute('gql', GraphQLInstanceTest::class);
        return GraphQLInstanceTest::$gql;
    }

    /**
     * @depends testGraphQLInstanceExists
     */
    function testGraphQLInstanceHasInstanceOfGraphQLObjectType(TypeObjectDefinition $gql)
    {
        $this->assertObjectHasAttribute('type', $gql);
        $this->assertInstanceOf(ObjectType::class, $gql->type);
    }

    /**
     * @depends testGraphQLInstanceExists
     */
    function testSendBasicGraphQLQuery(TypeObjectDefinition $gql)
    {
        $schema = new Schema([
            'query' => $gql->type
        ]);
        $result = (array) GraphQL::executeQuery($schema, 'query { string_field }', new GraphQLInstanceTest());
        $this->assertArrayHasKey('errors', $result);
        $this->assertArrayHasKey('data', $result);
        $this->assertEmpty($result['errors']);
        $this->assertNotEmpty($result['data']);
        return $result;
    }

    /**
     * @depends testSendBasicGraphQLQuery
     */
    function testStringFieldResult($result)
    {
        $this->assertArrayHasKey('string_field', $result['data']);
        $this->assertEquals('This is an instance value', $result['data']['string_field']);
    }
}
