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

import com.qifun.jsonStream.crossPlatformTypes.StmMap;
import com.qifun.jsonStream.ItemEntities.Item;

@:final
class IT1 extends Item
{
  public function GetHashCode():Int return 0;
  public function Equals(other:Dynamic)
  {
    return Std.is(other, IT1);
  }
}

@:final
class IT2 extends Item
{
  public function GetHashCode():Int return 0;
  public function Equals(other:Dynamic)
  {
    return Std.is(other, IT2);
  }
}

@:final
class IT3 extends Item
{
  public function GetHashCode():Int return 0;
  public function Equals(other:Dynamic)
  {
    return Std.is(other, IT3);
  }
}

@:final
class IT4 extends Item
{
  public function GetHashCode():Int return 0;
  public function Equals(other:Dynamic)
  {
    return Std.is(other, IT4);
  }
}

@:final
class IT5 extends Item
{
  public function GetHashCode():Int return 0;
  public function Equals(other:Dynamic)
  {
    return Std.is(other, IT5);
  }
}

class Item
{

	public function new()
	{

	}

}

@:final
class CSharpItems
{

  public function new() { }
	public var items:StmMap<Item, Int> = StmMap.empty();
}

