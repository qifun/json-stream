package com.qifun.jsonStream;

using com.qifun.jsonStream.Plugins;

@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["com.qifun.jsonStream.UserEntities"]))
class UserEntitiesSerializer { }

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["com.qifun.jsonStream.UserEntities"]))
class UserEntitiesDeserializer { }


@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["com.qifun.jsonStream.TypeEntities"]))
class TypeEntitiesSerializer { }

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["com.qifun.jsonStream.TypeEntities"]))
class TypeEntitiesDeserializer { }


@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["com.qifun.jsonStream.StmEntity"]))
class StmEntitySerializer { }

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["com.qifun.jsonStream.StmEntity"]))
class StmEntityDeserializer { }


@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(["com.qifun.jsonStream.AbstractEntities"]))
class AbstractSerializer { }

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(["com.qifun.jsonStream.AbstractEntities"]))
class AbstractDeserializer { }