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

package com.qifun.jsonStream.deserializerPlugin;

#if (cs || macro)

import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.ds.Vector;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;
import haxe.macro.Context;
import haxe.macro.TypeTools;
#if cs
import dotnet.system.collections.generic.List;
import dotnet.system.collections.generic.Dictionary;
import dotnet.system.collections.generic.HashSet;
#end
/**
  ```cs.System.Collection.Generic.List```的序列化插件。
**/
@:final
class CSharpListDeserializerPlugin
{
  #if cs
  @:noUsing
  @:dox(hide)
  public static function deserializeForElement<Element>(stream:JsonDeserializerPluginStream<dotnet.system.collections.generic.List<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<dotnet.system.collections.generic.List<Element>> return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(value):
      {
        var list = new dotnet.system.collections.generic.List<Element>();
        var generator = Std.instance(value, (Generator:Class<Generator<JsonStream>>));
        if (generator != null)
        {
          for (element in generator)
          {
            list.Add(elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
          }
        }
        else
        {
          for (element in value)
          {
            list.Add(elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
          }
        }
        list;
      }
      case NULL:
        null;
      case stream :
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY" , "NULL" ]);
    }
  }
  #end

  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<dotnet.system.collections.generic.List<Element>>>):ExprOf<Null<dotnet.system.collections.generic.List<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.CSharpDeserializerPlugins.CSharpListDeserializerPlugin.deserializeForElement($self, function(substream) return substream.pluginDeserialize());
  }
}


/**
  ```cs.System.Collection.Generic.Dictionary```的序列化插件。
**/
@:final
class CSharpDictionaryDeserializerPlugin
{
  #if cs
  @:noUsing
  @:dox(hide)
  public static function deserializeForElement<Key, Value>(
    stream:JsonDeserializerPluginStream<dotnet.system.collections.generic.Dictionary<Key, Value>>,
    keyDeserializeFunction:JsonDeserializerPluginStream<Key>->Key,
    valueDeserializeFunction:JsonDeserializerPluginStream<Value>->Value):
    Null<dotnet.system.collections.generic.Dictionary<Key, Value>> return
  {
    switch (stream.underlying)
    {
      case ARRAY(iterator):
      {
        var dictionary = new dotnet.system.collections.generic.Dictionary<Key, Value>();
        var generator = Std.instance(iterator, (Generator:Class<Generator<JsonStream>>));
        if (generator == null)
        {
          while(iterator.hasNext())
          {
            switch (iterator.next())
            {
              case com.qifun.jsonStream.JsonStream.ARRAY(pairIterator):
              {
                if (pairIterator.hasNext())
                {
                  var keyStream = pairIterator.next();
                  var key = keyDeserializeFunction(new JsonDeserializerPluginStream(keyStream));
                  if (pairIterator.hasNext())
                  {
                    var valueStream = pairIterator.next();
                    var value = valueDeserializeFunction(new JsonDeserializerPluginStream(valueStream));
                    dictionary.Add(key, value);
                    if (pairIterator.hasNext())
                    {
                      throw JsonDeserializerError.TOO_MANY_FIELDS(pairIterator, 2);
                    }
                  }
                  else
                  {
                    throw JsonDeserializerError.NOT_ENOUGH_FIELDS(iterator, 2, 1);
                  }
                }
                else
                {
                  throw JsonDeserializerError.NOT_ENOUGH_FIELDS(iterator, 2, 0);
                }
              }
              case stream: throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY" ]);
            }
          }
        }
        else
        {
          while(generator.hasNext())
          {
            switch (generator.next())
            {
              case com.qifun.jsonStream.JsonStream.ARRAY(pairIterator):
              {
                if (pairIterator.hasNext())
                {
                  var keyStream = pairIterator.next();
                  var key = keyDeserializeFunction(new JsonDeserializerPluginStream(keyStream));
                  if (pairIterator.hasNext())
                  {
                    var valueStream = pairIterator.next();
                    var value = valueDeserializeFunction(new JsonDeserializerPluginStream(valueStream));
                    dictionary.Add(key, value);
                    if (pairIterator.hasNext())
                    {
                      throw JsonDeserializerError.TOO_MANY_FIELDS(pairIterator, 2);
                    }
                  }
                  else
                  {
                    throw JsonDeserializerError.NOT_ENOUGH_FIELDS(iterator, 2, 1);
                  }
                }
                else
                {
                  throw JsonDeserializerError.NOT_ENOUGH_FIELDS(iterator, 2, 0);
                }
              }
              case stream: throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY" ]);
            }
          }
        }
        dictionary;
      }
      case NULL:
        null;
      case stream:
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY" , "NULL" ]);
    }
  }
  #end

  macro public static function pluginDeserialize<Key, Value>(self:ExprOf<JsonDeserializerPluginStream<dotnet.system.collections.generic.Dictionary<Key, Value>>>):ExprOf<Null<dotnet.system.collections.generic.Dictionary<Key, Value>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.CSharpDeserializerPlugins.CSharpDictionaryDeserializerPlugin.deserializeForElement($self, function(substream1) return substream1.pluginDeserialize(), function(substream2) return substream2.pluginDeserialize());
  }
}


/**
  ```cs.System.Collection.Generic.HashSet```的序列化插件。
**/
@:final
class CSharpHashSetDeserializerPlugin
{
  #if cs
  @:noUsing
  @:dox(hide)
  public static function deserializeForElement<Element>(stream:JsonDeserializerPluginStream<dotnet.system.collections.generic.HashSet<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<dotnet.system.collections.generic.HashSet<Element>> return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(value):
      {
        var hashSet = new dotnet.system.collections.generic.HashSet<Element>();
        var generator = Std.instance(value, (Generator:Class<Generator<JsonStream>>));
        if (generator != null)
        {
          for (element in generator)
          {
            hashSet.Add(elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
          }
        }
        else
        {
          for (element in value)
          {
            hashSet.Add(elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
          }
        }
        hashSet;
      }
      case NULL:
        null;
      case stream :
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY" , "NULL" ]);
    }
  }
  #end

  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<dotnet.system.collections.generic.HashSet<Element>>>):ExprOf<Null<dotnet.system.collections.generic.HashSet<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.CSharpDeserializerPlugins.CSharpHashSetDeserializerPlugin.deserializeForElement($self, function(substream) return substream.pluginDeserialize());
  }
}

#end
