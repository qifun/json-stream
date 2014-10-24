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

import haxe.ds.IntMap;
import haxe.ds.Vector;

@:final
class IntMapEntities
{
  public function new() { }
  public var intData = new IntMap<Int>();
  public var stringData = new IntMap<String>();
  public var floatData = new IntMap<Float>();
  //public var vectorData = new IntMap<Vector<Int>>();
  public var arrayData = new IntMap<Array<Int>>();
  public var nullableIntData = new IntMap<Null<Int>>();
  public var nullableArrayData = new IntMap<Null<Array<Int>>>();

}
