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
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.RawJson;
import com.qifun.jsonStream.testUtil.JsonTestCase;
import com.qifun.jsonStream.SimpleEntities;
using com.qifun.jsonStream.Plugins;
using com.qifun.jsonStream.SimpleIo;

class SimpleTest extends JsonTestCase
{

  function testEmptyBuilder()
  {
    var builder:JsonBuilder<SimpleClass> = JsonBuilderFactory.newBuilder();
    builder.setObject().end();
    assertEquals(null, builder.result.foo);
  }

  function testNullBuilder()
  {
    var builder:JsonBuilder<SimpleClass> = JsonBuilderFactory.newBuilder();
    builder.setNull();
    assertEquals(null, builder.result);
  }

  function testUnmatchedBuilder()
  {
    var builder:JsonBuilder<SimpleClass> = JsonBuilderFactory.newBuilder();
    try
    {
      builder.setNumber(1.1);
    }
    catch (builderError:JsonBuilderError)
    {
      assertMatch(UNMATCHED_JSON_TYPE(NUMBER(1.1), [ "OBJECT", "NULL" ]), builderError);
    }
  }

  function testAddString()
  {
    var builder:JsonBuilder<SimpleClass> = JsonBuilderFactory.newBuilder();
    {
      var objectBuilder = builder.setObject();
      objectBuilder.addString("foo", "bar");
      objectBuilder.end();
    }
    assertEquals("bar", builder.result.foo);
  }

  function testSetStream()
  {
    var builder:JsonBuilder<SimpleClass> = JsonBuilderFactory.newBuilder();
    builder.setStream(JsonSerializer.serializeRaw(new RawJson( { foo: "bar" } )));
    assertEquals(builder.result.foo, "bar");
  }

  function testSerializer()
  {
    var data = new SimpleClass();
    data.foo = "bar";
    assertDeepEquals({ foo: "bar" }, JsonDeserializer.deserializeRaw(JsonSerializer.serialize(data)));
  }

  function testSimple()
  {
    JsonTestCase.testData(new SimpleAbstract("baz"));
    JsonTestCase.testData([1]);
    JsonTestCase.testData([SimpleEnum.ENUM_VALUE_1]);
    JsonTestCase.testData(1);
    JsonTestCase.testData(SimpleEnum.ENUM_VALUE_1);
  }


}
