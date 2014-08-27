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

package com.qifun.jsonStream.serializerPlugin;

import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.unknown.UnknownType;
import haxe.macro.Expr.ExprOf;
#if macro
import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Type;
#end

/**
  支持序列化`Dynamic`类型的插件。
**/
class LowPriorityDynamicSerializerPlugin
{

  @:noDynamicSerialize
  macro public static function pluginSerialize(
    self:ExprOf<JsonSerializerPluginData<LowPriorityDynamic>>):ExprOf<JsonStream> return
  {
    switch (Context.follow(Context.typeof(self)))
    {
      case TAbstract(_, [ expectedType ]):
        JsonSerializerGenerator.dynamicSerialize(
          macro $self.underlying,
          TypeTools.toComplexType(expectedType));
      case _:
        throw "Expected JsonSerializerPluginData";
    }
  }

}

