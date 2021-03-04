<?php

class Util {
    public static function getFieldDefinitionByName($field_array, $name)
    {
        $field_array = $field_array->arr;
        foreach($field_array as $item) {
            if($item->name === $name) {
                return $item;
            }
        }
        return null;
    }
}