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

#if (cs || macro)

import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import haxe.macro.Context;
import haxe.macro.TypeTools;
#if cs
import dotnet.system.collections.generic.List;
import dotnet.system.collections.generic.IEnumerator;
import dotnet.system.collections.generic.Dictionary;
import dotnet.system.collections.generic.HashSet;
#end

/**
  ```cs.System.Collection.Generic.List```的序列化插件。
**/
@:final
class CSharpListSerializerPlugin
{

  #if cs
  @:noUsing
  @:dox(hide)
  public static function serializeForElement<Element>(data:JsonSerializerPluginData<dotnet.system.collections.generic.List<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (data == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        var enumerator:IEnumerator<Element> = data.underlying.GetEnumerator();
        while(enumerator.MoveNext())
        {
          yield(elementSerializeFunction(new JsonSerializerPluginData(enumerator.Current))).async();
        }
      })));
    }
  }
  #end

  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<dotnet.system.collections.generic.List<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.CSharpSerializerPlugins.CSharpListSerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }

}


/**
  ```cs.System.Collection.Generic.Dictionary```的序列化插件。
**/
@:final
class CSharpDictionarySerializerPlugin
{
  #if cs
  @:dox(hide)
  @:noUsing
  public static function serializeForElement<Key, Value>(
    data:JsonSerializerPluginData<dotnet.system.collections.generic.Dictionary<Key, Value>>,
    KeySerializeFunction:JsonSerializerPluginData<Key>->JsonStream,
    ValueSerializeFunction:JsonSerializerPluginData<Value>->JsonStream):JsonStream return
  {
    if (data == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        var enumerator:IEnumerator<dotnet.system.collections.generic.KeyValuePair<Key, Value>> = data.underlying.GetEnumerator();
        while (enumerator.MoveNext())
        {
          yield(ARRAY(
          new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
          {
            yield(KeySerializeFunction(new JsonSerializerPluginData(enumerator.Current.Key))).async();
            yield(ValueSerializeFunction(new JsonSerializerPluginData(enumerator.Current.Value))).async();
          })))).async();
        }
      })));
    }
  }
  #end

  macro public static function pluginSerialize<Key, Value>(self:ExprOf<JsonSerializerPluginData<dotnet.system.collections.generic.Dictionary<Key, Value>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.CSharpSerializerPlugins.CSharpDictionarySerializerPlugin.serializeForElement($self, function(subdata1) return subdata1.pluginSerialize(), function(subdata2) return subdata2.pluginSerialize());
  }
}



/**
  ```cs.System.Collection.Generic.HashSet```的序列化插件。
**/
@:final
class CSharpHashSetSerializerPlugin
{
  #if cs
  @:dox(hide)
  @:noUsing
  public static function serializeForElement<Element>(data:JsonSerializerPluginData<dotnet.system.collections.generic.HashSet<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (data == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        var enumerator:IEnumerator<Element> = data.underlying.GetEnumerator();
        while(enumerator.MoveNext())
        {
          yield(elementSerializeFunction(new JsonSerializerPluginData(enumerator.Current))).async();
        }
      })));
    }
  }
  #end

  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<dotnet.system.collections.generic.HashSet<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.CSharpSerializerPlugins.CSharpHashSetSerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }
}
#end
