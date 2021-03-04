<?php

use PHPUnit\Framework\TestCase;
use graphql\GraphQLTypes;

class TypesTest extends TestCase
{
    function testString()
    {
        $this->assertEquals('String', GraphQLTypes::String);
    }
    
    function testInteger()
    {
        $this->assertEquals('Integer', GraphQLTypes::Int);
    }
}
