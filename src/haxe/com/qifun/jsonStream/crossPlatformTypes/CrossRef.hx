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

package com.qifun.jsonStream.crossPlatformTypes;

#if (scala && java)
#if scala_stm
typedef NativeRef<A> = scala.concurrent.stm.Ref<A>;
#else
typedef NativeRef<A> = A;
#end
#elseif cs
typedef NativeRef<A> = A;
#else
typedef NativeRef<A> = A;
#end

abstract CrossRef<A>(NativeRef<A>)
{

  public var underlying(get, never):NativeRef<A>;

  @:extern
  inline function get_underlying():NativeRef<A> return
  {
    this;
  }

  inline public function new(ref:NativeRef<A>)
  {
    this = ref;
  }
}
