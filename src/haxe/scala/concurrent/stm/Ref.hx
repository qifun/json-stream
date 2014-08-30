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

package scala.concurrent.stm;

#if (java && scala)
import haxe.Int64;
import java.StdTypes;
import scala.reflect.OptManifest;

extern interface Ref<A> extends scala.concurrent.stm.RefLike<A, scala.concurrent.stm.InTxn>
{
  public function single():scala.concurrent.stm.RefView<A>;
}


@:native("scala.concurrent.stm.Ref$")
extern class RefSingleton_Single
{
  @:native("MODULE$") public static var MODULE(default, never):RefSingleton_Single;

  public function apply(initialValue:Single):Ref<Dynamic>;

}

@:native("scala.concurrent.stm.Ref$")
extern class RefSingleton
{

  @:native("MODULE$") public static var MODULE(default, never):RefSingleton;

  @:overload(function(initialValue:Int):Ref<Dynamic>{})
  @:overload(function(initialValue:Bool):Ref<Dynamic>{})
  @:overload(function(initialValue:Float):Ref<Dynamic>{})
  @:overload(function(initialValue:Int64):Ref<Dynamic>{})
  @:overload(function(initialValue:Int8):Ref<Dynamic>{})
  @:overload(function(initialValue:Int16):Ref<Dynamic>{})
  @:overload(function(initialValue:Char16):Ref<Dynamic>{})
  public function apply<A>(initialValue: A, om: OptManifest<A>): Ref<A>;

}


//
  //public function apply<A>(initialValue: A, om: OptManifest<A>): Ref<A>;
//
  //@:native("apply")
  //public function applyBool(initialValue:Bool):Ref<Bool>;
//
  //@:native("apply")
  //public function applySingle(initialValue:Single):Ref<Single>;
//
  //@:native("apply")
  //public function applyFloat(initialValue:Float):Ref<Float>;
//
  //@:native("apply")
  //public function applyInt(initialValue:Int):Ref<Int>;
//
  //@:native("apply")
  //public function applyInt64(initialValue:Int64):Ref<Int64>;
#end
