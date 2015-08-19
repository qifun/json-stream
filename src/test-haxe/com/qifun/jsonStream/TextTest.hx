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
import com.qifun.jsonStream.io.PrettyTextPrinter;
import com.qifun.jsonStream.io.TextParser;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.RawJson;
import com.qifun.jsonStream.testUtil.JsonTestCase;
import haxe.io.BytesOutput;
import haxe.Json;
import haxe.io.StringInput;

class TextTest extends JsonTestCase
{

  public function testNumberLiteral()
  {
    var text = "{\"numberField\":-33.799232482910156}";
    var nativeData2:Dynamic = JsonDeserializer.deserializeRaw(TextParser.parseString(text));
    #if haxe_320
    assertEquals(-33.799232482910156, nativeData2.numberField);
    #else
    assertTrue(Math.abs(-33.799232482910156 - nativeData2.numberField) < 0.000000000001);
    #end
  } 

  public function testUnicodeEscape()
  {
    var text = "{\"textField\":\"\\u4e2d文 \\uD83D\\uDC33\"}";
    var nativeData2:Dynamic = JsonDeserializer.deserializeRaw(TextParser.parseString(text));
    assertEquals("中文 🐳", nativeData2.textField);
  }

  public function testParser()
  {
    var nativeData =
    {
      field1: 123,
      field2: 8.0,
      field3: "foo",
      field4: ([ "foo", null, [], "bar", ([ ([ [], 2, null, { a: 0, } ]:Array<Dynamic>), "baz", [], ]: Array<Dynamic>), { b: null } ]: Array<Dynamic>),
      field5: null,
    }
    var text = Json.stringify(nativeData);
    var nativeData2 = JsonDeserializer.deserializeRaw(TextParser.parseString(text));
    assertDeepEquals(nativeData, nativeData2);
  }

  public function testPrinter()
  {
    var nativeData =
    {
      field1: 123,
      field2: 8.0,
      field3: "foo",
      field4: ([ "foo", null, [], "bar", ([ ([ [], 2, null, { a: 0, } ]:Array<Dynamic>), "baz", [], ]: Array<Dynamic>), { b: null } ]: Array<Dynamic>),
      field5: null,
    }
    var output = new BytesOutput();
    PrettyTextPrinter.print(output, JsonSerializer.serializeRaw(new RawJson(nativeData)));
    var text = output.getBytes().toString();
    var nativeData2 = Json.parse(text);
    assertDeepEquals(nativeData, nativeData2);
  }


  public function testParser2()
  {
    var nativeData =
      { "items": [ [ ( { "com/qifun/jsonStream/IT1": { }} :Dynamic), (99:Dynamic) ], [ ( { "com/qifun/jsonStream/IT1": { }} :Dynamic), (99:Dynamic) ], [ ( { "com/qifun/jsonStream/IT1": { }} :Dynamic), (99:Dynamic) ] ] };
    var text = Json.stringify(nativeData);
    var nativeData2 = JsonDeserializer.deserializeRaw(TextParser.parseString(text));
    assertDeepEquals(nativeData, nativeData2);
  }

  public function testPrinter2()
  {
    var nativeData =
      { "items": [ [ ( { "com/qifun/jsonStream/IT1": { }} :Dynamic), (99:Dynamic) ], [ ( { "com/qifun/jsonStream/IT1": { }} :Dynamic), (99:Dynamic) ], [ ( { "com/qifun/jsonStream/IT1": { }} :Dynamic), (99:Dynamic) ] ] };
    var output = new BytesOutput();
    PrettyTextPrinter.print(output, JsonSerializer.serializeRaw(new RawJson(nativeData)));
    var text = output.getBytes().toString();
    var nativeData2 = Json.parse(text);
    assertDeepEquals(nativeData, nativeData2);
  }



}
