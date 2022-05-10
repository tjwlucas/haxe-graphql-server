package graphql;

/**
	Enum of the valid metadata values which have special meaning in the GraphQL schema generation
**/
enum abstract FieldMetadata(String) from String to String {
    var Hide = "GraphQLHide";
    var Deprecated = "deprecationReason";
    var TypeName = "typeName";
    var MutationTypeName = "mutationName";
    var Validate = "validate";
    var ValidateAfter = "validateResult";
    var ValidationContext = "validationContext";
    var MutationField = "mutation";
    var QueryField = "query";
    var ClassValidationContext = ValidationContext;
    var ContextVar = "context";
    var DocMeta = "doc";
    var Deferred = "deferred";
    var Optional = "optional";
}