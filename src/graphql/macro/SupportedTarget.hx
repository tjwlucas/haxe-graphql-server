package graphql.macro;

enum abstract SupportedTarget(String) from String to String {
    var Javascript = "JavaScript";
    var Php = "PHP";
}