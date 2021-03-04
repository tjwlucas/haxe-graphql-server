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

    function testAllFieldDefinitionsHaveName()
    {
        $this->assertIsArray(SimpleClass::$gql_fields->arr);
        foreach(SimpleClass::$gql_fields->arr as $field) {
            $this->assertObjectHasAttribute('name', $field);
        }
    }

    function getFieldDefinitionByName($field_array, $name)
    {
        $field_array = $field_array->arr;
        foreach($field_array as $item) {
            if($item->name === $name) {
                return $item;
            }
        }
        return null;
    }

    function testGraphQLFieldListDefinesSimpleStringField()
    {
        $simple_string_field = $this->getFieldDefinitionByName(SimpleClass::$gql_fields, 'simple_string_field');
        $this->assertNotNull($simple_string_field);
    }

    /**
     * @depends testGraphQLFieldListDefinesSimpleStringField
     */
    function testGraphQLSimpleStringFieldHasType()
    {
        $simple_string_field = $this->getFieldDefinitionByName(SimpleClass::$gql_fields, 'simple_string_field');
        $this->assertObjectHasAttribute('type', $simple_string_field);
    }

    /**
     * @depends testGraphQLSimpleStringFieldHasType
     * @depends testGraphQLFieldListDefinesSimpleStringField
     */
    function testGraphQLSimpleStringFieldTypeValue()
    {
        $simple_string_field = $this->getFieldDefinitionByName(SimpleClass::$gql_fields, 'simple_string_field');
        $this->assertEquals('String', $simple_string_field->type);
    }

    /**
     * @depends testGraphQLFieldListDefinesSimpleStringField
     */
    function testGraphQLSimpleStringFieldHasComment()
    {
        $simple_string_field = $this->getFieldDefinitionByName(SimpleClass::$gql_fields, 'simple_string_field');
        $this->assertObjectHasAttribute('comment', $simple_string_field);
    }

    /**
     * @depends testGraphQLSimpleStringFieldHasComment
     * @depends testGraphQLFieldListDefinesSimpleStringField
     */
    function testGraphQLSimpleStringFieldCommentValue()
    {
        $simple_string_field = $this->getFieldDefinitionByName(SimpleClass::$gql_fields, 'simple_string_field');
        $this->assertEquals('This is the `simple_string_field` documentation', $simple_string_field->comment);
    }
}
