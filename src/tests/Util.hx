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
	
	public static function getArgMaps(field : GraphQLField) : Array<Map<String, Dynamic>> {
		#if php
			var result = [for(arg in field.args) graphql.Util.hashOfAssociativeArray(arg)];
		#elseif js
			var result = [for(arg in Reflect.fields(field.args)) graphql.Util.hashOfAssociativeArray(Reflect.field(field.args, arg))]; 
		#else
			var result = [for(arg in field.args.toHaxeArray()) graphql.Util.hashOfAssociativeArray(arg)];
		#end
		return result;
	}
}
