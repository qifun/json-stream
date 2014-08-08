using com.qifun.jsonStream.Plugins;


@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["CSharpSimple"]))
class CSharpSimpleSerializer
{
}


@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["CSharpSimple"]))
class CSharpSimpleDeserializer
{
}