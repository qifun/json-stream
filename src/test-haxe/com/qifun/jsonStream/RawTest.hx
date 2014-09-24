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
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.RawJson;
import haxe.ds.Option;
import haxe.Json;
import com.qifun.jsonStream.testUtil.JsonTestCase;
import haxe.unit.TestCase;


class RawTest extends JsonTestCase
{

  function testObject()
  {
    inline function selectLatter<T>(former:T, latter:T):T return latter;

    var nativeData =
    {
      field1: 123,
      field2: 8.0,
      field3: "foo",
      field4: ([ "foo", null, [], "bar", ([ ([ [], 2, null, { a: 0, } ]:Array<Dynamic>), "baz", [], ]: Array<Dynamic>), { b: null } ]: Array<Dynamic>),
      field5: null,
    }
    var data = new RawJson(nativeData);
    var stream = JsonSerializer.serializeRaw(data);
    var data2 = JsonDeserializer.deserializeRaw(stream);
    var nativeData2 = selectLatter(nativeData, data2.underlying);
    assertMatch(
      {
        field1: 123,
        field2: 8.0,
        field3: "foo",
        field4: [ "foo", null, (_:Array<Dynamic>) => [], "bar", (_:Array<Dynamic>) => [ (_:Array<Dynamic>) => [ (_:Array<Dynamic>) => [], 2, null, (_: { ?a:Int }) => { a: 0, } ], "baz", (_:Array<Dynamic>) => [], ], (_: { ?b:Dynamic }) => { b: null } ],
        field5: null,
      },
      nativeData2);
    assertDeepEquals(data, data2);
  }

}
