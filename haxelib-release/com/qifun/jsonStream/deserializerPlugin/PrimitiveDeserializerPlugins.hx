package com.qifun.jsonStream.deserializerPlugin;

import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;
import haxe.Int64;
import haxe.macro.Context;
import haxe.macro.TypeTools;

@:final
class Int64DeserializerPlugin
{

  @:extern
  @:noUsing
  private static inline function extractInt64(iterator:Iterator<JsonStream>):Int64 return
  {
    if (iterator.hasNext())
    {
      var element0 = iterator.next();
      switch (element0)
      {
        case NUMBER(high):
          if (iterator.hasNext())
          {
            throw JsonDeserializeError.TOO_MANY_FIELDS(iterator, 2);
          }
          else
          {
            if (iterator.hasNext())
            {
              var element1 = iterator.next();
              switch (element1)
              {
                case NUMBER(low):
                  if (iterator.hasNext())
                  {
                    throw JsonDeserializeError.TOO_MANY_FIELDS(iterator, 2);
                  }
                  else
                  {
                    Int64.make(cast high, cast low);
                  }
                case _:
                  throw JsonDeserializeError.UNMATCHED_JSON_TYPE(element1, [ "NUMBER" ]);
              }
            }
            else
            {
              throw JsonDeserializeError.NOT_ENOUGH_FIELDS(iterator, 2, 1);
            }
          }
        case _:
          throw JsonDeserializeError.UNMATCHED_JSON_TYPE(element0, [ "NUMBER" ]);
      }
    }
    else
    {
      throw JsonDeserializeError.NOT_ENOUGH_FIELDS(iterator, 2, 0);
    }
  }

  @:extern
  @:noUsing
  private static inline function optimizedExtractInt64(iterator:Iterator<JsonStream>):Int64 return
  {
    var generator = Std.instance(iterator, (Generator:Class<Generator<JsonStream>>));
    if (generator == null)
    {
      extractInt64(iterator);
    }
    else
    {
      extractInt64(generator);
    }
  }
  
  public static function pluginDeserialize(stream:JsonDeserializerPluginStream<Int64>):Null<Int64> return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(elements):
        optimizedExtractInt64(elements);
      case NULL:
        null;
      case _:
        throw "Expect number";
    }
  }
}

@:final
class IntDeserializerPlugin
{
  public static function pluginDeserialize(stream:JsonDeserializerPluginStream<Int>):Null<Int> return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.NUMBER(value):
        cast value;
      case NULL:
        null;
      case _:
        throw "Expect number";
    }
  }
}

@:final
class UIntDeserializerPlugin
{
  public static function pluginDeserialize(stream:JsonDeserializerPluginStream<UInt>):Null<UInt> return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.NUMBER(value):
        cast value;
      case NULL:
        null;
      case _:
        throw "Expect number";
    }
  }
}

#if (java || cs)
  @:final
  class SingleDeserializerPlugin
  {
    public static function pluginDeserialize(stream:JsonDeserializerPluginStream<Single>):Null<Single> return
    {
      switch (stream.underlying)
      {
        case com.qifun.jsonStream.JsonStream.NUMBER(value):
          value;
        case NULL:
          null;
        case _:
          throw "Expect number";
      }
    }
  }
#end

@:final
class FloatDeserializerPlugin
{
  public static function pluginDeserialize(stream:JsonDeserializerPluginStream<Float>):Null<Float> return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.NUMBER(value):
        value;
      case NULL:
        null;
      case _:
        throw "Expect number";
    }
  }
}

@:final
class BoolDeserializerPlugin
{
  public static function pluginDeserialize(stream:JsonDeserializerPluginStream<Bool>):Null<Bool> return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.FALSE: false;
      case com.qifun.jsonStream.JsonStream.TRUE: true;
      case NULL:
        null;
      case _: throw "Expect false | true";
    }
  }
}

@:final
class StringDeserializerPlugin
{
  public static function pluginDeserialize(stream:JsonDeserializerPluginStream<String>):Null<String> return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.STRING(value):
        value;
      case NULL:
        null;
      case _:
        throw "Expect string";
    }
  }
}

@:final
class ArrayDeserializerPlugin
{

  @:dox(hide)
  public static function deserializeForElement<Element>(stream:JsonDeserializerPluginStream<Array<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<Array<Element>> return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(value):
        var generator = Std.instance(value, (Generator:Class<Generator<JsonStream>>));
        if (generator != null)
        {
          [
            for (element in generator)
            {
              elementDeserializeFunction(new JsonDeserializerPluginStream(element));
            }
          ];
        }
        else
        {
          [
            for (element in value)
            {
              elementDeserializeFunction(new JsonDeserializerPluginStream(element));
            }
          ];
        }
      case NULL:
        null;
      case _:
        throw "Expect array";
    }
  }
  
  macro public static function pluginDeserialize<Element>(stream:ExprOf<JsonDeserializerPluginStream<Array<Element>>>):ExprOf<Null<Array<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.ArrayDeserializerPlugin.deserializeForElement($stream, function(substream) return substream.pluginDeserialize());
  }
}

//TODO : StringMap and IntMap
