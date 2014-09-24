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

#if (scala && java)
typedef StmNativeVector<A> = scala.concurrent.stm.TArray<A>;
#else
typedef StmNativeVector<A> = haxe.ds.Vector<A>;
#end
/**
  因为haxe的bug，值类型，如```Int```、```Double```等在java以及scala平台无法编译通过
**/
abstract StmVector<A>(StmNativeVector<A>)
{
  public var underlying(get, never):StmNativeVector<A>;

  @:extern
  inline function get_underlying():StmNativeVector<A> return
  {
    this;
  }

  inline public function new(underlying:StmNativeVector<A>)
  {
    this = underlying;
  }
  
  public static inline function empty<A>(length:Int):StmVector<A> return
  {
  #if (scala && java)
    var tarrayView:scala.concurrent.stm.TArrayView<A> = scala.concurrent.stm.japi.STM.newTArray(length);
    new StmVector(tarrayView.tarray());
  #else
    new StmVector<A>(new haxe.ds.Vector(length));
  #end
  }
}