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

package com.qifun.jsonStream;
import haxe.ds.Vector;

interface IHasArray<A>
{
  var array:Array<A>;
}

class BaseClass<B, A>
{
  public function new() {}

  public var a1:A;
  public var array:Array<A>;
  public var self:Null<BaseClass<A, BaseClass<B, Int>>>;
  public var self2(default, default):Null<BaseClass<A, B>>;
}

class BaseClass2<A, B, C> extends BaseClass<Array<B>, A> implements IHasArray<A>
{

  public var a2:A;
  var array2:Array<IHasArray<C>>;
  var array3:Array<IHasArray<FinalClass<Dynamic>>>;
  var vector5:Vector<C>;

}

@:final
class FinalClass<G> extends BaseClass2<Array<Array<BaseClass<G, BaseClass<G, Dynamic>>>>, String, Array<G>>
{
  var array4:Array<FinalClass<Dynamic>>;
}

@:final
class FinalClass2<A, B> extends BaseClass<A,B>
{
  //var vector1:Vector<Int>; // 由于Haxe的bug，Java平台无法使用Vector<Int>
  var vector2:Vector<A>;
  var vector3:Vector<B>;
  var vector4:Vector<String>;
}
