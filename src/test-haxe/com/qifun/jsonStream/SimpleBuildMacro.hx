package com.qifun.jsonStream;
using com.qifun.jsonStream.Plugins;

@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["com.qifun.jsonStream.SimpleEntities"]))
class SimpleSerializer
{
}


@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["com.qifun.jsonStream.SimpleEntities"]))
class SimpleDeserializer
{
}


@:build(com.qifun.jsonStream.JsonBuilderFactory.generateBuilderFactory(["com.qifun.jsonStream.SimpleEntities"]))
class SimpleBuilderFactory
{
}
