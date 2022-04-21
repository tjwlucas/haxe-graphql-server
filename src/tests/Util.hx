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
	
	#if js
	static function objectToMap(object:Dynamic) : Map<String, Dynamic> {
		var map : Map<String, Dynamic> = [];
		for(key in Reflect.fields(object)) {
			map[key] = Reflect.field(object, key);
		}
		return map;
	}
	#end
	
	public static function getArgMaps(field : GraphQLField) : Array<Map<String, Dynamic>> {
		#if php
			return [for(arg in field.args) graphql.Util.hashOfAssociativeArray(arg)];
		#elseif js
			var result = [for(arg in Reflect.fields(field.args)) graphql.Util.hashOfAssociativeArray(objectToMap(Reflect.field(field.args, arg)))]; 
			return result;
		#else
			return [for(arg in field.args.toHaxeArray()) graphql.Util.hashOfAssociativeArray(arg)];
		#end
	}
}
