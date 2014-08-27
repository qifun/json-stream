/*
 * json-stream
 * Copyright 2014 深圳岂凡网络有限公司 (Shenzhen QiFun Network Corp., LTD)
 * 
 * Author: 杨博 (Yang Bo) <pop.atry@gmail.com>, 张修羽 (Zhang Xiuyu) <95850845@qq.com>
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
using com.qifun.jsonStream.Plugins;
using com.qifun.jsonStream.GenericClassIo;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.GenericClasses;
import com.qifun.jsonStream.testUtil.JsonTestCase;

class GenericClassTest extends JsonTestCase
{
  function testEmpty()
  {
    JsonTestCase.testData(new FinalClass<Int>());
    JsonTestCase.testData(new FinalClass<Dynamic>());
    JsonTestCase.testData(new FinalClass<haxe.Int64>());
    JsonTestCase.testData(new FinalClass<StringBuf>());
    JsonTestCase.testData(new BaseClass<Int, StringBuf>());
    JsonTestCase.testData(new BaseClass2<FinalClass<Int>, Int, StringBuf>());
    JsonTestCase.testData(new BaseClass2<Dynamic, Int, StringBuf>());
  }

  function testComplex()
  {
    var data = new BaseClass2<FinalClass<Int>, Int, StringBuf > ();
    data.array =
    [
      {
        var data = new FinalClass<Int>();
        data.array = [ [ [], null, [ null ]], null ];
        // Workaround for https://github.com/HaxeFoundation/haxe/issues/3118
        #if cs (data:Dynamic) #else data #end .a2 =
        [
          [ null, ],
          [
            {
              var data = new FinalClass2<Int, BaseClass<Int, Dynamic>>();
              data.a1 =
              {
                var data = new FinalClass2<Int, Dynamic>();
                data.a1 = "";
                data;
              }
              data;
            },
            null,
            new BaseClass<Int, BaseClass <Int, Dynamic>>(),
          ]
        ];
        data.self2 =
        {
          var data = new FinalClass2<Array<Array<BaseClass<Int, BaseClass<Int, Dynamic>>>>, Array<String>>();
          data.self = new BaseClass<Array<String>, BaseClass<Array<Array<BaseClass<Int, BaseClass<Int, Dynamic>>>>, Int>>();
          // Workaround for https://github.com/HaxeFoundation/haxe/issues/3118
          #if cs (data:Dynamic) #else data #end.a1 = [ null, null, null ];
          data.array =
          [
            [ "foo" ],
            [ "bar", "baz", "", null]
          ];
          data;
        }
        data;
      },
    ];
    JsonTestCase.testData(data);
  }


}
