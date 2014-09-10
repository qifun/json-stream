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
typedef StmNativeMap<Key, Value> = scala.concurrent.stm.TMap<Key, Value>;
#elseif cs
typedef StmNativeMap<Key, Value> = dotnet.system.collections.generic.Dictionary<Key, Value>;
#else
import Map in StdMap;
typedef StmNativeMap<Key, Value> = StdMap<Key, Value>;
#end

abstract StmMap<Key, Value>(StmNativeMap<Key, Value>)
{

  public inline function add(key:Key, value:Value):Void
  {
    #if cs
      this.Add(key, value);
    #elseif (scala && java)
      this.single().update(key, value);
    #else
      throw "Unsupported platform!";
    #end
  }

  public var underlying(get, never):StmNativeMap<Key, Value>;

  @:extern
  inline function get_underlying():StmNativeMap<Key, Value> return
  {
    this;
  }

  public inline function new(map:StmNativeMap<Key, Value>)
  {
    this = map;
  }

  public static inline function empty<Key, Value>():StmMap<Key, Value> return
  {
  #if (scala && java)
    var mapView:scala.concurrent.stm.TMapView<Key, Value> = scala.concurrent.stm.japi.STM.MODULE.newTMap();
    new StmMap(mapView.tmap());
  #elseif cs
    new StmMap(new dotnet.system.collections.generic.Dictionary<Key, Value>());
  #else
    throw "Unsupported platform!";
  #end
  }
}
