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


import haxe.macro.*;
import haxe.macro.Expr;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonSerializer;

@:final
class CrossPlatformRefSerializerPlugin
{
  
  @:noDynamicSerialize
  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<com.qifun.jsonStream.crossPlatformTypes.CrossRef<Element>>>):ExprOf<JsonStream> return
  {
    if (Context.defined("java") && Context.defined("scala") && Context.defined("scala_stm"))
    {
      macro com.qifun.jsonStream.serializerPlugin.StmSerializerPlugins.StmRefSerializerPlugin.serializeForElement(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData($self.underlying.underlying), function(substream) return substream.pluginSerialize());
    }
    else
    {
      macro new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData($self.underlying.underlying).pluginSerialize();
    }
  }

}

@:final
class CrossPlatformVectorSerializerPlugin
{

  @:noDynamicSerialize
  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<com.qifun.jsonStream.crossPlatformTypes.CrossVector<Element>>>):ExprOf<JsonStream> return
  {
    if (Context.defined("java") && Context.defined("scala") && Context.defined("scala_stm"))
    {
      macro com.qifun.jsonStream.serializerPlugin.StmSerializerPlugins.StmTArraySerializerPlugin.serializeForElement(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData($self.underlying.underlying), function(substream) return substream.pluginSerialize());
    }
    else
    {
      macro com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.VectorSerializerPlugin.serializeForElement(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData($self.underlying.underlying), function(substream) return substream.pluginSerialize());
    }
  }

}


@:final
class CrossPlatformSetSerializerPlugin
{

  @:noDynamicSerialize
  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<com.qifun.jsonStream.crossPlatformTypes.CrossSet<Element>>>):ExprOf<JsonStream> return
  {
    if (Context.defined("java") && Context.defined("scala"))
    {
      if (Context.defined("scala_stm"))
      {
        macro com.qifun.jsonStream.serializerPlugin.StmSerializerPlugins.StmTSetSerializerPlugin.serializeForElement(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData($self.underlying.underlying), function(substream) return substream.pluginSerialize());
      }
      else
      {
        macro com.qifun.jsonStream.serializerPlugin.ScalaSerializerPlugins.ScalaSetSerializerPlugin.serializeForElement(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData($self.underlying.underlying), function(substream) return substream.pluginSerialize());
      }
    }
    else if (Context.defined("cs"))
    {
      macro com.qifun.jsonStream.serializerPlugin.CSharpSerializerPlugins.CSharpHashSetSerializerPlugin.serializeForElement(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData($self.underlying.underlying), function(substream) return substream.pluginSerialize());
    }
    else
    {
      Context.error("Unsupported platform", Context.currentPos());
    }
  }

}


@:final
class CrossPlatformMapSerializerPlugin
{

  @:noDynamicSerialize
  macro public static function pluginSerialize<Key, Value>(self:ExprOf<JsonSerializerPluginData<com.qifun.jsonStream.crossPlatformTypes.CrossMap<Key, Value>>>):ExprOf<JsonStream> return
  {
    if (Context.defined("java") && Context.defined("scala"))
    {
      if (Context.defined("scala_stm"))
      {
        macro com.qifun.jsonStream.serializerPlugin.StmSerializerPlugins.StmTMapSerializerPlugin.serializeForElement(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData($self.underlying.underlying), function(substream) return substream.pluginSerialize(), function(substream) return substream.pluginSerialize());
      }
      else
      {
        macro com.qifun.jsonStream.serializerPlugin.ScalaSerializerPlugins.ScalaMapSerializerPlugin.serializeForElement(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData($self.underlying.underlying), function(substream) return substream.pluginSerialize(), function(substream) return substream.pluginSerialize());
      }
    }
    else if (Context.defined("cs"))
    {
      macro com.qifun.jsonStream.serializerPlugin.CSharpSerializerPlugins.CSharpDictionarySerializerPlugin.serializeForElement(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData($self.underlying.underlying), function(substream) return substream.pluginSerialize(), function(substream) return substream.pluginSerialize());
    }
    else
    {
      throw "";
      Context.error("Unsupported platform", Context.currentPos());
    }
  }

}
