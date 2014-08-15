package com.qifun.jsonStream;
using com.qifun.jsonStream.Plugins;

@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["com.qifun.jsonStream.GenericClasses"]))
class GenericClassSerializer
{
}


@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["com.qifun.jsonStream.GenericClasses"]))
class GenericClassDeserializer
{
}


@:build(com.qifun.jsonStream.JsonBuilderFactory.generateBuilderFactory(["com.qifun.jsonStream.GenericClasses"]))
class GenericClassBuilderFactory
{
}

