package tests;

import php.Lib;
import graphql.GraphQLField;

class Util {
	public static function getFieldDefinitionByName(fieldList:Array<GraphQLField>, name:String) : Null<GraphQLField> {
		for (field in fieldList) {
			if (field.name == name) {
				return field;
			}
		}
		return null;
	}

	public static function getArgMaps(field : GraphQLField) : Array<Map<String, Dynamic>> {
		return [for(arg in field.args) Lib.hashOfAssociativeArray(arg)];
	}
}
