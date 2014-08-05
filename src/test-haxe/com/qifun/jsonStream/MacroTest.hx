package com.qifun.jsonStream;

using com.qifun.jsonStream.Plugins;

@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["com.qifun.jsonStream.UserTest"]))
class UserTestSerializer { }

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["com.qifun.jsonStream.UserTest"]))
class UserTestDeserializer { }


@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["com.qifun.jsonStream.TypeTest"]))
class TypeTestSerializer { }

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["com.qifun.jsonStream.TypeTest"]))
class TypeTestDeserializer { }


@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["com.qifun.jsonStream.STMTest"]))
class STMTestSerializer { }

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["com.qifun.jsonStream.STMTest"]))
class STMTestDeserializer { }
