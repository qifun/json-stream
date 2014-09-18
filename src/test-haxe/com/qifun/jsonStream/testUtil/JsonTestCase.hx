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

package com.qifun.jsonStream.testUtil;
#if macro
import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.macro.Expr;
import haxe.macro.*;
#end
import com.qifun.jsonStream.JsonDeserializer;
import haxe.unit.TestCase;
import haxe.PosInfos;

@:autoBuild(com.qifun.jsonStream.testUtil.JsonTestCase.build())
class JsonTestCase extends TestCase
{

  macro public static function build():Array<Field>
  {
    var localClass = Context.getLocalClass().get();
    var fields = Context.getBuildFields();
    if (TypeTools.findField(localClass, "main", true) == null)
    {
      var localClassName = localClass.name;
      var localModule = localClass.module;
      var moduleLast = switch (localModule.lastIndexOf("."))
      {
        case -1: localModule;
        case dotIndex: localModule.substring(dotIndex + 1);
      }
      var localTypaPath =
        {
          pack: localClass.pack,
          sub: localClass.name,
          name: moduleLast,
        };
      fields.push(
        {
          name: "main",
          pos: Context.currentPos(),
          access: [ AStatic ],
          kind: FFun(
            {
              args: [],
              ret: null,
              expr: macro
              {
                new $localTypaPath().delayedRun();
              }
            })
        });
    }
    return fields;
  }

  function delayedRun()
  {
    function run()
    {
      var runner = new haxe.unit.TestRunner();
      runner.add(this);
      var isSuccess = runner.run();
      if (!isSuccess)
      {
        throw runner.result;
      }
    }
    #if flash
      haxe.Timer.delay(run, 0);
    #else
      run();
    #end
  }

  macro static function testData<T>(data:ExprOf<T>):ExprOf<Void> return
  {
    var dataComplexType = TypeTools.toComplexType(Context.typeof(data));
    macro
    {
      {
        var builder:com.qifun.jsonStream.JsonBuilder<$dataComplexType> =
          com.qifun.jsonStream.JsonBuilderFactory.newBuilder();
        var stream = com.qifun.jsonStream.JsonSerializer.serialize($data);
        builder.setStream(stream);
        assertDeepEquals(
          com.qifun.jsonStream.JsonDeserializer.deserializeRaw(
            com.qifun.jsonStream.JsonSerializer.serialize($data)),
          com.qifun.jsonStream.JsonDeserializer.deserializeRaw(
            com.qifun.jsonStream.JsonSerializer.serialize(builder.result)));
      }
      {
        var stream = com.qifun.jsonStream.JsonSerializer.serialize($data);
        var data2:$dataComplexType = com.qifun.jsonStream.JsonDeserializer.deserialize(stream);
        assertDeepEquals(
          com.qifun.jsonStream.JsonDeserializer.deserializeRaw(
            com.qifun.jsonStream.JsonSerializer.serialize($data)),
          com.qifun.jsonStream.JsonDeserializer.deserializeRaw(
            com.qifun.jsonStream.JsonSerializer.serialize(data2)));
      }
    }


  }

  macro function assertMatch(self:Expr, expected:Expr, actual:Expr):Expr return
  {
    var prefix = "expected '" + ExprTools.toString(expected) + "' but was '";
    macro
    {
      $self.currentTest.done = true;
      switch ($actual)
      {
        case $expected: // Fine
        default:
        {
          $self.currentTest.success = false;
          $self.currentTest.error   = $v{prefix} + $actual + "'";
          inline function getPosInfos(?c : haxe.PosInfos) return c;
          $self.currentTest.posInfos = getPosInfos();
          throw $self.currentTest;
        }
      }
    }
  }

  function assertDeepEquals(expected: Dynamic, actual: Dynamic, ?c : PosInfos):Void
 	{
		currentTest.done = true;
		if (!JsonEquality.deepEquals(actual, expected)){
			currentTest.success = false;
			currentTest.error   = "expected '" + expected + "' but was '" + actual + "'";
			currentTest.posInfos = c;
			throw currentTest;
		}
	}

}
