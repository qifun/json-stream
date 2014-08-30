/*
 * json-stream
 * Copyright 2014 深圳岂凡网络有限公司 (Shenzhen QiFun Network Corp., LTD)
 * 
 * Author: 杨博 (Yang Bo) <pop.atry@gmail.com>, 张修羽 (Zhang Xiuyu) <zxiuyu@126.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
