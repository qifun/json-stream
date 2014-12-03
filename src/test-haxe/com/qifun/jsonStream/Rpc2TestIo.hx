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
using com.qifun.jsonStream.rpc.Future;
import com.qifun.jsonStream.rpc.OutgoingProxyFactory;
using com.qifun.jsonStream.Plugins;
import com.qifun.jsonStream.testUtil.JsonTestCase;

class Rpc2TestIo extends JsonTestCase
{

  function foo()
  {
    var s:Future<Int->String->Void> = null;
//    s.onComplete(function(i:Int, s:String){}, function(e){});

  }

}

@:build(com.qifun.jsonStream.rpc.OutgoingProxyFactory.generateOutgoingProxyFactory(["com.qifun.jsonStream.Services"]))
class Rpc2OutgoingProxyFactory
{

}



@:build(com.qifun.jsonStream.rpc.IncomingProxyFactory.generateIncomingProxyFactory(["com.qifun.jsonStream.Services"]))
class Rpc2IncomingProxyFactory
{

}

