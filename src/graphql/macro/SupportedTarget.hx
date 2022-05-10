package graphql.macro;

/**
    List of supported targets
**/
enum abstract SupportedTarget(String) from String to String {
    var Javascript = "JavaScript";
    var Php = "PHP";
}