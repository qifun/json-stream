using com.qifun.jsonStream.Plugins;


@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["CSharpTest"]))
class CSharpTestSerializer
{
}


@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["CSharpTest"]))
class CSharpTestDeserializer
{
}