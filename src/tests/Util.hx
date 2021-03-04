package tests;

class Util {
    public static function getFieldDefinitionByName(fieldList : Array<graphql.GraphQLField>, name:String ) {
        for(field in fieldList) {
            if(field.name == name) {
                return field;
            }
        }
        return null;
    }
}