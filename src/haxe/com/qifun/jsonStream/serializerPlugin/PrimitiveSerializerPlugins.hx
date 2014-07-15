package com.qifun.jsonStream.serializerPlugin;

import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import haxe.ds.Vector;
import haxe.Int64;

@:final
class Int64SerializerPlugin
{
  /* inline */ // 如果加入inline，会导致Java平台编译错误
  public static function pluginSerialize(self:JsonSerializerPluginData<Int64>):JsonStream return
  {
    if (self == null)
    {
      NULL;
    }
    else
    {
      ARRAY(
        new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
        {
          yield(NUMBER(Int64.getHigh(self.underlying))).async();
          yield(NUMBER(Int64.getLow(self.underlying))).async();
        })));
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
    self == null ? NULL : NUMBER(self.underlying);
  }
}

@:final
class IntSerializerPlugin
{
  public static inline function pluginSerialize(self:JsonSerializerPluginData<Int>):JsonStream return
  {
    self.underlying == null ? NULL : NUMBER(self.underlying);
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

  public static function serializeForElement<Element>(self:JsonSerializerPluginData<Array<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (self.underlying == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        for (element in self.underlying)
        {
          yield(elementSerializeFunction(new JsonSerializerPluginData(element))).async();
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

  public static function serializeForElement<Element>(self:JsonSerializerPluginData<Vector<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (self.underlying == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        for (i in 0...self.underlying.length)
        {
          var element = self.underlying[i];
          yield(elementSerializeFunction(new JsonSerializerPluginData(element))).async();
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
