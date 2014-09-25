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

package com.qifun.jsonStream.crossPlatformTypes;

#if (scala && java && scala_stm)
typedef NativeVector<A> = scala.concurrent.stm.TArray<A>;
#else
typedef NativeVector<A> = haxe.ds.Vector<A>;
#end
/**
  由于Haxe Bug，本类型的序列化在Java平台是坏的。不要使用本类。参见 https://github.com/qifun/json-stream/issues/21
**/
abstract CrossVector<A>(NativeVector<A>)
{
  public var underlying(get, never):NativeVector<A>;

  @:extern
  inline function get_underlying():NativeVector<A> return
  {
    this;
  }

  inline public function new(underlying:NativeVector<A>)
  {
    this = underlying;
  }
}
