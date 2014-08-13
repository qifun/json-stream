package com.qifun.jsonStream;

import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonBuilderFactory;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.rpc.IncomingProxy;
import com.qifun.jsonStream.rpc.OutgoingProxy;

using com.qifun.jsonStream.Plugins;
using com.qifun.jsonStream.Io;

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer(
[
  "com.qifun.jsonStream.Ping",
  "com.qifun.jsonStream.Pong",
]))
class Deserializer {}

@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer(
[
  "com.qifun.jsonStream.Ping",
  "com.qifun.jsonStream.Pong",
]))
class Serializer {}


@:build(com.qifun.jsonStream.rpc.OutgoingProxyFactory.generateOutgoingProxyFactory(
[
  "com.qifun.jsonStream.IPingPong",
]))
class OutgoingProxyFactory { }

@:build(com.qifun.jsonStream.rpc.IncomingProxyFactory.generateIncomingProxyFactory(
[
  "com.qifun.jsonStream.IPingPong",
]))
class IncomingProxyFactory { }
