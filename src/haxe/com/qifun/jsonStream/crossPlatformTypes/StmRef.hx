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
typedef StmNativeRef<A> = scala.concurrent.stm.Ref<A>;
#elseif cs
typedef StmNativeRef<A> = A;
#else
typedef StmNativeRef<A> = A;
#end

abstract StmRef<A>(StmNativeRef<A>)
{
  public var underlying(get, never):StmNativeRef<A>;

  @:extern
  inline function get_underlying():StmNativeRef<A> return
  {
    this;
  }

  inline public function new(?ref:StmNativeRef<A>)
  {
    if (ref == null)
    {
      #if (scala && java)
        var refView:scala.concurrent.stm.RefView<A> = scala.concurrent.stm.japi.STM.MODULE.newRef(null);
        this = refView.ref();
      #elseif cs
        this = null;
      #end
    }
    else
    {
      this = ref;
    }
  }
}