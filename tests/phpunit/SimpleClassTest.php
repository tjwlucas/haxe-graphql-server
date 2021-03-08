<?php

use PHPUnit\Framework\TestCase;
use tests\cases\SimpleClass;
use tests\Util;
use graphql\GraphQLTypes;
use graphql\TypeObjectDefinition;
use GraphQL\Type\Definition\Type;

class SimpleClassTest extends TestCase
{
    function testMagicGraphqlFieldExists()
    {
        $this->assertClassHasStaticAttribute('gql', SimpleClass::class);
        return SimpleClass::$gql;
    }
    
    /**
     * @params TypeObjectDefinition $gql
     * @depends testMagicGraphqlFieldExists
     */
    function testGraphQLFieldListExists(TypeObjectDefinition $gql)
    {
        $this->assertObjectHasAttribute('fields', $gql);
        return $gql->fields;
    }
    
    /**
     * @params TypeObjectDefinition $gql
     * @depends testMagicGraphqlFieldExists
     */
    function testGraphQLTypeName(TypeObjectDefinition $gql)
    {
        $this->assertObjectHasAttribute('type_name', $gql);
        $this->assertIsString($gql->type_name);
        $this->assertEquals('SimpleClass', $gql->type_name);
    }

    /**
     * @depends testGraphQLFieldListExists
     */
    function testGraphQLFieldListIsHaxeArray($gql_fields)
    {
        $this->assertInstanceOf(\Array_hx::class, $gql_fields);
        $native_array = $gql_fields->arr;
        $this->assertIsArray($native_array);
        return $native_array;
    }

    /**
     * @depends testGraphQLFieldListIsHaxeArray
     */
    function testAllFieldDefinitionsHaveName($gql_fields_array)
    {
        $this->assertIsArray($gql_fields_array);
        foreach ($gql_fields_array as $field) {
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
        $this->assertEquals(GraphQLTypes::$String, $simple_string_field->type);
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

    /**
     * @depends testGraphQLFieldListExists
     * Test that a field marked with @:GraphQLHide metadata should *not* appear in the schema
     */
    function testDeprecatedStringFieldExists($gql_fields)
    {
        $deprecated_string_field = Util::getFieldDefinitionByName($gql_fields, 'deprecated_string_field');
        $this->assertNotNull($deprecated_string_field);
        return $deprecated_string_field;
    }

    /**
     * @depends testGraphQLFieldListDefinesSimpleStringField
     */
    function testNonDeprecatedStringFieldHasNullDeprecationReason($simple_string_field)
    {
        $this->assertObjectHasAttribute('deprecationReason', $simple_string_field);
        $this->assertNull($simple_string_field->deprecationReason);
    }

    /**
     * @depends testDeprecatedStringFieldExists
     */
    function testDeprecatedStringFieldHasDeprecationReason($deprecated_string_field)
    {
        $this->assertObjectHasAttribute('deprecationReason', $deprecated_string_field);
        $reason = $deprecated_string_field->deprecationReason;
        $this->assertNotNull($reason);
        return $reason;
    }

    /**
     * @depends testDeprecatedStringFieldHasDeprecationReason
     */
    function testDeprecatedStringFieldDeprecationReasonValue($reason)
    {
        $this->assertEquals('With a deprecation reason', $reason);
    }

    /**
     * @depends testGraphQLFieldListExists
     */
    function testGraphQLFieldListDefinesIntField($gql_fields)
    {
        $int_field = Util::getFieldDefinitionByName($gql_fields, 'int_field');
        $this->assertNotNull($int_field);
        return $int_field;
    }

    /**
     * @depends testGraphQLFieldListDefinesIntField
     */
    function testGraphQLIntFieldHasType($int_field)
    {
        $this->assertObjectHasAttribute('type', $int_field);
    }

    /**
     * @depends testGraphQLFieldListDefinesIntField
     */
    function testGraphQLIntFieldTypeValue($int_field)
    {
        $this->assertEquals(GraphQLTypes::$Int, $int_field->type);
    }

    /**
     * @depends testGraphQLFieldListExists
     */
    function testGraphQLFieldListDefinesIntArrayField($gql_fields)
    {
        $int_array_field = Util::getFieldDefinitionByName($gql_fields, 'int_array');
        $this->assertNotNull($int_array_field);
        return $int_array_field;
    }

    /**
     * @depends testGraphQLFieldListDefinesIntArrayField
     */
    function testGraphQLIntArrayFieldHasType($int_array_field)
    {
        $this->assertObjectHasAttribute('type', $int_array_field);
    }

    /**
     * @depends testGraphQLFieldListDefinesIntArrayField
     */
    function testGraphQLIntArrayFieldTypeValue($int_array_field)
    {
        $this->assertEquals(Type::listOf(Type::int()), $int_array_field->type);
    }

    /**
     * @depends testGraphQLFieldListExists
     */
    function testGraphQLFieldListDefinesNestedIntArrayField($gql_fields)
    {
        $nested_int_array = Util::getFieldDefinitionByName($gql_fields, 'nested_int_array');
        $this->assertNotNull($nested_int_array);
        return $nested_int_array;
    }

    /**
     * @depends testGraphQLFieldListDefinesNestedIntArrayField
     */
    function testGraphQLNestedIntArrayFieldHasType($nested_int_array_field)
    {
        $this->assertObjectHasAttribute('type', $nested_int_array_field);
    }

    /**
     * @depends testGraphQLFieldListDefinesNestedIntArrayField
     */
    function testGraphQLNestedIntArrayFieldTypeValue($nested_int_array_field)
    {
        $this->assertEquals(Type::listOf(Type::listOf(Type::listOf(Type::int()))), $nested_int_array_field->type);
    }
}
