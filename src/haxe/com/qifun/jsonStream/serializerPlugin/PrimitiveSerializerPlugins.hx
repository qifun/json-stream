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

#if macro
class IterableArray<Element>
{
  var list:List<JsonStream> = new List<JsonStream>();
  var iterator:Iterator<JsonStream>;
  public function new<Element>(array:Array<Element>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):Void
  {
    for (element in array)
      list.push(elementSerializeFunction(new JsonSerializerPluginData(element)));
    iterator = list.iterator();
  }
  public function hasNext():Bool return 
  {
    iterator.hasNext();
  }
  public function next():JsonStream return
  {
    iterator.next();
  }
}
#end

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
    #if macro
    {
      ARRAY(new IterableArray<Element>(data.underlying, elementSerializeFunction));
    }
    #else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        for (element in data.underlying)
        {
          @await yield(elementSerializeFunction(new JsonSerializerPluginData(element)));
        }
      })));
    }
    #end
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
#if macro
//TODO : StringMap and IntMap
class IterablePair<Value>
{
  private var pos:Int = 0;
  
  var key:JsonStream;
  
  var value:JsonStream;
  
  public function new<Value>(k:String, v:Value, ValueSerializeFunction:JsonSerializerPluginData<Value>->JsonStream):Void
  {
    key = StringSerializerPlugin.pluginSerialize(new JsonSerializerPluginData(k));
    value = ValueSerializeFunction(new JsonSerializerPluginData(v));
  }
  
  public function hasNext():Bool return
  {
    if (pos < 2)
      true;
    else 
      false;
  }
  
  public function next():JsonStream return
  {
    switch (pos)
    {
      case 0:++pos; key;
      case 1:++pos; value;
      default:throw "has no more element.";
    }
  }
}

class IterableMap<Value>
{
  var elements:Array<JsonStream> = [];
  
  var pos:Int = 0;
  
  public function new(map:StringMap<Value>, valueSerializeFunction:JsonSerializerPluginData<Value>->JsonStream):Void
  {
    var keys = map.keys();
    while (keys.hasNext())
    {
      var key = keys.next();
      elements.push(ARRAY(new IterablePair(key, map.get(key), valueSerializeFunction)));
    }
  }
  
  public function hasNext():Bool return 
  {
    if (pos < elements.length)
      true;
    else
      false;  
  }
  
  public function next():JsonStream return
  {
    if (pos < elements.length)
      elements[pos++];
    else throw "has no more element.";
  }
}
#end
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
      #if macro
      ARRAY(new IterableMap(data.underlying, ValueSerializeFunction));
      #else
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
      #end
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