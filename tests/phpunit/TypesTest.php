<?php

use PHPUnit\Framework\TestCase;
use graphql\GraphQLTypes;
use GraphQL\Type\Definition\Type;

class TypesTest extends TestCase
{
    function testString()
    {
        $this->assertEquals(Type::string(), GraphQLTypes::$String);
    }
    
    function testInteger()
    {
        $this->assertEquals(Type::int(), GraphQLTypes::$Int);
    }
}
