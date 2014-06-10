using com.qifun.jsonStream.Plugins;

@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["SimpleEntities"]))
class SimpleSerializer
{
}


@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["SimpleEntities"]))
class SimpleDeserializer
{
}


@:build(com.qifun.jsonStream.JsonBuilderFactory.generateBuilderFactory(["SimpleEntities"]))
class SimpleBuilderFactory
{
}
