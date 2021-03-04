<?php

use PHPUnit\Framework\TestCase;
use tests\cases\SimpleClass;

class SimpleClassTest extends TestCase
{
    function testGraphQLFieldListExists()
    {
        $this->assertClassHasStaticAttribute('gql_fields', SimpleClass::class);
    }

    /**
     * @depends testGraphQLFieldListExists
     */
    function testGraphQLFieldListIsHaxeArray()
    {
        $this->assertInstanceOf(\Array_hx::class , SimpleClass::$gql_fields);
    }

    function testGraphQLFieldListHasName()
    {
        $field_array = SimpleClass::$gql_fields->arr;
        $first_field = $field_array[0];
        $this->assertObjectHasAttribute('name', $first_field);
    }

    /**
     * @depends testGraphQLFieldListHasName
     */
    function testGraphQLFieldListNameValue()
    {
        $field_array = SimpleClass::$gql_fields->arr;
        $first_field = $field_array[0];
        $this->assertEquals('simple_string_field', $first_field->name);
    }

    function testGraphQLFieldListHasType()
    {
        $field_array = SimpleClass::$gql_fields->arr;
        $first_field = $field_array[0];
        $this->assertObjectHasAttribute('type', $first_field);
    }

    /**
     * @depends testGraphQLFieldListHasType
     */
    function testGraphQLFieldListTypeValue()
    {
        $field_array = SimpleClass::$gql_fields->arr;
        $first_field = $field_array[0];
        $this->assertEquals('String', $first_field->type);
    }

    function testGraphQLFieldListHasComment()
    {
        $field_array = SimpleClass::$gql_fields->arr;
        $first_field = $field_array[0];
        $this->assertObjectHasAttribute('comment', $first_field);
    }

    /**
     * @depends testGraphQLFieldListHasName
     */
    function testGraphQLFieldListTypeComment()
    {
        $field_array = SimpleClass::$gql_fields->arr;
        $first_field = $field_array[0];
        $this->assertEquals('This is the `simple_string_field` documentation', $first_field->comment);
    }
}
