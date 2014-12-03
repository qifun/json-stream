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

package com.qifun.jsonStream.serializerPlugin;

import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.Vector;
import haxe.Int64;
import haxe.io.Bytes;


@:final
class Int64SerializerPlugin
{

  private static function toInt64(d:Dynamic):Int64 return
  {
    #if java
    untyped __java__("(long)d");
    #else
    d;
    #end
  }

  @:noDynamicSerialize
  /* inline */ // 如果加入inline，会导致Java平台编译错误
  public static function pluginSerialize(self:JsonSerializerPluginData<Int64>):JsonStream return
  {
    if (self == null)
    {
      NULL;
    }
    else
    {
      var i64 = (self:Dynamic);
      INT64(Int64.getHigh(toInt64(i64)), Int64.getLow(toInt64(i64)));
    }
  }
}

@:final
class UIntSerializerPlugin
{

  @:noDynamicSerialize
  /* inline */ // 如果加入inline，会导致Java平台编译错误
  public static function pluginSerialize(self:JsonSerializerPluginData<UInt>):JsonStream return
  {
    self == null ? NULL : INT32(self.underlying);
  }
}

@:final
class IntSerializerPlugin
{
  public static inline function pluginSerialize(self:JsonSerializerPluginData<Int>):JsonStream return
  {
    self.underlying == null ? NULL : INT32(self.underlying);
  }
}

#if (java || cs)
  @:final
  class SingleSerializerPlugin
  {
    @:noDynamicSerialize
    public static inline function pluginSerialize(self:JsonSerializerPluginData<Single>):JsonStream return
    {
      self.underlying == null ? NULL : NUMBER(self.underlying);
    }
  }
#end

@:final
class FloatSerializerPlugin
{
  public static inline function pluginSerialize(self:JsonSerializerPluginData<Float>):JsonStream return
  {
    self.underlying == null ? NULL : NUMBER(self.underlying);
  }
}

@:final
class BoolSerializerPlugin
{
  public static inline function pluginSerialize(self:JsonSerializerPluginData<Bool>):JsonStream return
  {
    switch (self.underlying)
    {
      case null: NULL;
      case true: TRUE;
      case false: FALSE;
    }
  }
}

@:final
class BinarySerializerPlugin
{
  public static function pluginSerialize(self:JsonSerializerPluginData<Bytes>):JsonStream return
  {
    self.underlying == null ? NULL : BINARY(self.underlying);
  }
}

@:final
class StringSerializerPlugin
{
  public static inline function pluginSerialize(self:JsonSerializerPluginData<String>):JsonStream return
  {
    self.underlying == null ? NULL : STRING(self.underlying);
  }
}

@:final
class ArraySerializerPlugin
{

  // 注意：data不能使用Array<Element>类型。
  // 如果用了Array<Element>类型，typer在执行pluginSerialize时，会展开pluginSerialize参数中的abstract，
  // 从而导致生成dynamicSerialize函数时，插件类型推断错误。
  @:dox(hide)
  @:noUsing
  public static function serializeForElement<Element>(data:JsonSerializerPluginData<Array<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (data == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        for (element in data.underlying)
        {
          @await yield(elementSerializeFunction(new JsonSerializerPluginData(element)));
        }
      })));
    }
  }

  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<Array<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.ArraySerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }
}

@:final
class VectorSerializerPlugin
{

  @:dox(hide)
  @:noUsing
  public static function serializeForElement<Element>(data:JsonSerializerPluginData<Vector<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (data == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        var i = 0;
        while (i < data.underlying.length)
        {
          var element = data.underlying[i];
          i += 1;
          @await yield(elementSerializeFunction(new JsonSerializerPluginData(element)));
        }
      })));
    }
  }

  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<Vector<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.VectorSerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }
}

//TODO : StringMap and IntMap


@:final
class StringMapSerializerPlugin
{
  @:dox(hide)
  @:noUsing
  public static function serializeForElement<Value>(
    data:JsonSerializerPluginData<StringMap<Value>>,
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
        var keys = data.underlying.keys();
        while (keys.hasNext())
        {
          @await yield(ARRAY(
          new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
          {
            var elementKey = keys.next();
            @await yield(StringSerializerPlugin.pluginSerialize(new JsonSerializerPluginData(elementKey)));
            @await yield(ValueSerializeFunction(new JsonSerializerPluginData(data.underlying.get(elementKey))));
          }))));
        }
      })));
    }
  }

  macro public static function pluginSerialize<Value>(self:ExprOf<JsonSerializerPluginData<StringMap<Value>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.StringMapSerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }
}


@:final
class IntMapSerializerPlugin
{
  @:dox(hide)
  @:noUsing
  public static function serializeForElement<Value>(
    data:JsonSerializerPluginData<IntMap<Value>>,
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
        var keys = data.underlying.keys();
        while (keys.hasNext())
        {
          @await yield(ARRAY(
          new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
          {
            var elementKey = keys.next();
            @await yield(IntSerializerPlugin.pluginSerialize(new JsonSerializerPluginData(elementKey)));
            @await yield(ValueSerializeFunction(new JsonSerializerPluginData(data.underlying.get(elementKey))));
          }))));
        }
      })));
    }
  }

  macro public static function pluginSerialize<Value>(self:ExprOf<JsonSerializerPluginData<IntMap<Value>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.IntMapSerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }
}