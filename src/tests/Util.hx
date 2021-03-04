package tests;

import graphql.GraphQLField;

class Util {
	public static function getFieldDefinitionByName(fieldList:Array<GraphQLField>, name:String) {
		for (field in fieldList) {
			if (field.name == name) {
				return field;
			}
		}
		return null;
	}
}
