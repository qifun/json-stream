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
import haxe.unit.TestCase;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.CustomJsonFieldNameEntities;
import com.qifun.jsonStream.testUtil.JsonTestCase;
import com.dongxiguo.continuation.utils.Generator;
import com.dongxiguo.continuation.Continuation;
import haxe.ds.Vector;

using com.qifun.jsonStream.Plugins;
using com.qifun.jsonStream.CustomJsonFieldNameIo;

class CustomJsonFieldNameTest extends JsonTestCase
{
  function testCustomJsonField()
  {
    var entity = new CustomJsonFieldName();
    entity.fooBar = 100;
    var jsonStream1 = JsonSerializer.serialize(entity);
    var raw = JsonDeserializer.deserializeRaw(jsonStream1);
    assertEquals(100, Reflect.field(raw, "foo-bar"));
    var jsonStream2 = JsonSerializer.serialize(entity);
    var entity2:CustomJsonFieldName = JsonDeserializer.deserialize(jsonStream2);
    assertDeepEquals(entity, entity2);
  }
}
