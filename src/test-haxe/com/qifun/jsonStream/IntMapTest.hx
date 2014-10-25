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
import com.qifun.jsonStream.testUtil.JsonTestCase;
import com.dongxiguo.continuation.utils.Generator;
import com.dongxiguo.continuation.Continuation;
import haxe.ds.Vector;

using com.qifun.jsonStream.Plugins;
using com.qifun.jsonStream.IntMapIo;

class IntMapTest extends JsonTestCase
{
 function testIntMap()
  {
		var imTest = new IntMapEntities();
		assertFalse(imTest == null);

		imTest.intData.set(1, 1);
		imTest.intData.set(2, 2);
		imTest.stringData.set(1, "a");
		imTest.stringData.set(2, "b");
		imTest.floatData.set(1, 1.0);
		imTest.floatData.set(1, 2.0);
		
		
		//var vectorData = new Vector<Int>(1);
		//vectorData .set(1,1);
		//imTest.vectorData.set("1", vectorData);
		
		var arrayData = new Array<Int>();
		arrayData .push(1);
		imTest.arrayData.set(1, arrayData);
		
		imTest.nullableIntData.set(1,null);
		imTest.nullableArrayData.set(1,null);
	  
		var jsonStream = JsonSerializer.serialize(imTest);
	  var imTest2:IntMapEntities = JsonDeserializer.deserialize(jsonStream);
	  assertDeepEquals(imTest, imTest2);
  }
}
