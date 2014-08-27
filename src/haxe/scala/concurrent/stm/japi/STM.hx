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

package scala.concurrent.stm.japi;

#if (java && scala_stm)


@:native("scala.concurrent.stm.japi.STM$")
extern class STM
{
  @:native("MODULE$") public static var MODULE(default, never):STM;
  
  public function newRef<A>(_:A):scala.concurrent.stm.RefView<A>;

  public function newTArray<A>(_:Int):scala.concurrent.stm.TArrayView<A>;
  
  public function newTSet<A>():scala.concurrent.stm.TSetView<A>;

  public function newTMap<A, B>():scala.concurrent.stm.TMapView<A, B>;


}
#end