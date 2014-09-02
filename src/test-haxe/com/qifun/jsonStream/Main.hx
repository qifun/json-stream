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
import haxe.unit.TestRunner;
import com.qifun.jsonStream.testUtil.JsonTestCase;
import com.qifun.jsonStream.CSharpPluginsTest;
import Rpc2Test;



class Main
{

  static function testAll()
  {
    var runner = new TestRunner();
    runner.add(new RawTest());
    runner.add(new SimpleTest());
    runner.add(new SimpleAbstractTest());
    runner.add(new EnumWithParameterTest());
    runner.add(new Rpc2Test());
    runner.add(new GenericClassTest());
    runner.add(new TextTest());
    runner.add(new CSharpPluginsTest());
    //runner.add(new AbstractPluginTest());
    var isSuccess = runner.run();
    if (!isSuccess)
    {
      throw runner.result;
    }
  }

  public static function main()
  {
    // 使用Timer以绕开在main中遇到异常时FlashDevelop调试器无法退出的Bug
    #if flash9
      haxe.Timer.delay(testAll, 0);
    #else
      testAll();
    #end
  }

}
