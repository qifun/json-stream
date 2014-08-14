package com.qifun.jsonStream.serializerPlugin;

import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
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

@:final
class ArraySerializerPlugin
{

  public static function serializeForElement<Element>(data:Array<Element>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (data == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        for (element in data)
        {
          yield(elementSerializeFunction(new JsonSerializerPluginData(element))).async();
        }
      })));
    }
  }

  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<Array<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.ArraySerializerPlugin.serializeForElement($self.underlying, function(subdata) return subdata.pluginSerialize());
  }
}

@:final
class VectorSerializerPlugin
{

  public static function serializeForElement<Element>(data:Vector<Element>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
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
        while (i < data.length)
        {
          var element = data[i];
          i += i;
          yield(elementSerializeFunction(new JsonSerializerPluginData(element))).async();
        }
      })));
    }
  }

  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<Vector<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.VectorSerializerPlugin.serializeForElement($self.underlying, function(subdata) return subdata.pluginSerialize());
  }
}

//TODO : StringMap and IntMap
