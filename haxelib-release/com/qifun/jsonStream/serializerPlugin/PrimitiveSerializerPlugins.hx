package com.qifun.jsonStream.serializerPlugin;

//import com.dongxiguo.continuation.utils.Generator;
//import com.qifun.jsonStream.JsonStream;
import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator.Generator;
import com.dongxiguo.continuation.utils.Generator.YieldFunction;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import haxe.Int64;

@:final
class Int64SerializerPlugin
{
  public static inline function pluginSerialize(data:JsonSerializerPluginData<Int64>):JsonStream return
  {
    if (data == null)
    {
      NULL;
    }
    else
    {
      ARRAY(
        new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
        {
          yield(NUMBER(Int64.getHigh(data.underlying))).async();
          yield(NUMBER(Int64.getLow(data.underlying))).async();
        })));
    }
  }
}

@:final
class IntSerializerPlugin
{
  public static inline function pluginSerialize(data:JsonSerializerPluginData<Int>):JsonStream return
  {
    data.underlying == null ? NULL : NUMBER(data.underlying);
  }
}

@:final
class UIntSerializerPlugin
{
  public static inline function pluginSerialize(data:JsonSerializerPluginData<UInt>):JsonStream return
  {
    var underlying:Null<UInt> = data.underlying;
    underlying == null ? NULL : NUMBER(underlying);
  }
}

#if (java || cs)
  @:final
  class SingleSerializerPlugin
  {
    public static inline function pluginSerialize(data:JsonSerializerPluginData<Single>):JsonStream return
    {
      data.underlying == null ? NULL : NUMBER(data.underlying);
    }
  }
#end

@:final
class FloatSerializerPlugin
{
  public static inline function pluginSerialize(data:JsonSerializerPluginData<Float>):JsonStream return
  {
    data.underlying == null ? NULL : NUMBER(data.underlying);
  }
}

@:final
class BoolSerializerPlugin
{
  public static inline function pluginSerialize(data:JsonSerializerPluginData<Bool>):JsonStream return
  {
    switch (data.underlying)
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
  public static inline function pluginSerialize(data:JsonSerializerPluginData<String>):JsonStream return
  {
    data.underlying == null ? NULL : STRING(data.underlying);
  }
}

@:final
class ArraySerializerPlugin
{

  public static function serializeForElement<Element>(data:JsonSerializerPluginData<Array<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (data.underlying == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(function(yield:YieldFunction<JsonStream>):Void
      {
        for (element in data.underlying)
        {
          yield(elementSerializeFunction(element)).async();
        }
      }));
    }
  }
  
  macro public static function pluginSerialize<Element>(data:ExprOf<JsonSerializerPluginData<Array<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.ArraySerializerPlugin.serializeForElement($data, function(subdata) return subdata.pluginSerialize());
  }
}

////TODO : StringMap and IntMap
