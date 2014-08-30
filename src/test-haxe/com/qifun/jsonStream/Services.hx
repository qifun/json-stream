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

import com.qifun.jsonStream.rpc.Future;

interface IRpc2
{

  public function foo<CC>(parameter1:CC, parameter2:Int):Future < Float > ;

  // Does not support unless https://github.com/HaxeFoundation/haxe/issues/3176 fixed
  // public function bar<CC>(parameter1:CC, parameter2:Int):Future<Array<CC>->Void>;

  public dynamic function baz(parameter1:String, parameter2:Int):Future < Float > ;

}
