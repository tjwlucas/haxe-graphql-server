<?php

use PHPUnit\Framework\TestCase;
use tests\cases\SimpleClass;
use tests\Util;

class SimpleClassTest extends TestCase
{
    function testGraphQLFieldListExists()
    {
        $this->assertClassHasStaticAttribute('gql_fields', SimpleClass::class);
        return SimpleClass::$gql_fields;
    }

    /**
     * @depends testGraphQLFieldListExists
     */
    function testGraphQLFieldListIsHaxeArray($gql_fields)
    {
        $this->assertInstanceOf(\Array_hx::class, $gql_fields);
    }

    /**
     * @depends testGraphQLFieldListExists
     */
    function testAllFieldDefinitionsHaveName($gql_fields)
    {
        $this->assertIsArray($gql_fields->arr);
        foreach ($gql_fields->arr as $field) {
            $this->assertObjectHasAttribute('name', $field);
        }
    }

    /**
     * @depends testGraphQLFieldListExists
     */
    function testGraphQLFieldListDefinesSimpleStringField($gql_fields)
    {
        $simple_string_field = Util::getFieldDefinitionByName($gql_fields, 'simple_string_field');
        $this->assertNotNull($simple_string_field);
        return $simple_string_field;
    }

    /**
     * @depends testGraphQLFieldListDefinesSimpleStringField
     */
    function testGraphQLSimpleStringFieldHasType($simple_string_field)
    {
        $this->assertObjectHasAttribute('type', $simple_string_field);
    }

    /**
     * @depends testGraphQLFieldListDefinesSimpleStringField
     */
    function testGraphQLSimpleStringFieldTypeValue($simple_string_field)
    {
        $this->assertEquals('String', $simple_string_field->type);
    }

    /**
     * @depends testGraphQLFieldListDefinesSimpleStringField
     */
    function testGraphQLSimpleStringFieldHasComment($simple_string_field)
    {
        $this->assertObjectHasAttribute('comment', $simple_string_field);
    }

    /**
     * @depends testGraphQLFieldListDefinesSimpleStringField
     */
    function testGraphQLSimpleStringFieldCommentValue($simple_string_field)
    {
        $this->assertEquals('This is the `simple_string_field` documentation', $simple_string_field->comment);
    }


    /**
     * @depends testGraphQLFieldListExists
     * Test that a field marked with @:GraphQLHide metadata should *not* appear in the schema
     */
    function testHiddenFieldNotInDefinition($gql_fields)
    {
        $this->assertNull(Util::getFieldDefinitionByName($gql_fields, 'hidden_field'));
    }
}
