using com.qifun.jsonStream.Plugins;

@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["GenericClasses"]))
class GenericClassSerializer
{
}


@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["GenericClasses"]))
class GenericClassDeserializer
{
}


@:build(com.qifun.jsonStream.JsonBuilderFactory.generateBuilderFactory(["GenericClasses"]))
class GenericClassBuilderFactory
{
}

