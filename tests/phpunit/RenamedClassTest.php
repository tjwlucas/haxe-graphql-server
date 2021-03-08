<?php

use PHPUnit\Framework\TestCase;
use tests\cases\RenamedClass;

class RenamedClassTest extends TestCase
{
    function testGraphQLTypeName()
    {
        $this->assertClassHasStaticAttribute('gql', RenamedClass::class);
        $gql = RenamedClass::$gql;
        $this->assertObjectHasAttribute('type_name', $gql);
        $this->assertIsString($gql->type_name);
        $this->assertEquals('RenamedForGraphQL', $gql->type_name);
    }
}
