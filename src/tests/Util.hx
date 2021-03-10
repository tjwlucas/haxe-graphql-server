package tests;

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
}
