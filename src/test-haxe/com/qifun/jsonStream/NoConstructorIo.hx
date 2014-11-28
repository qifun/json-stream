package com.qifun.jsonStream;
using com.qifun.jsonStream.deserializerPlugin.GeneratedDeserializerPlugin;
using com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins;
using com.qifun.jsonStream.deserializerPlugin.LowPriorityDynamicDeserializerPlugin;

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["com.qifun.jsonStream.NoConstructor"]))
class NoConstructorIo
{
}