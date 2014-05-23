package com.qifun.jsonStream.deserializerPlugin;

import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;
import haxe.Int64;

@:final
class Int64DeserializerPlugin
{
  
  macro private static function jsonArrayStreamToInt64(streamIterator:ExprOf<Iterator<JsonStream>>):ExprOf<Int64>
  {
    return macro
    {
      if ($streamIterator.hasNext())
      {
        var highStream = $streamIterator.next();
        if ($streamIterator.hasNext())
        {
          var lowStream = $streamIterator.next();
          if ($streamIterator.hasNext())
          {
            (throw "Expect exact two elements in the array for Int64":Int64);
          }
          else
          {
            switch ([ highStream, lowStream ])
            {
              case [ NUMBER(high), NUMBER(low) ]:
                Int64.make(cast high, cast low);
              case _:
                (throw "Expect exact two number in the array for Int64":Int64);
            }
          }
        }
        else
        {
          (throw "Expect exact two elements in the array for Int64":Int64);
        }
      }
      else
      {
        (throw "Expect exact two elements in the array for Int64":Int64);
      }
      
    }
    
  }
  
  @:protected
  private static function optimizedJsonArrayStreamToInt64(streamIterator:Iterator<JsonStream>):Int64
  {
    var generator = Std.instance(streamIterator, (Generator:Class<Generator<JsonStream>>));
    if (generator !=  null)
    {
      return jsonArrayStreamToInt64(generator);
    }
    else
    {
      return jsonArrayStreamToInt64(streamIterator);
    }
  }

  public static function deserialize(stream:JsonDeserializerPluginStream<Int64>):Int64 return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(elements):
        optimizedJsonArrayStreamToInt64(elements);
      case _:
        throw "Expect number";
    }
  }
}

@:final
class IntDeserializerPlugin
{
  public static function deserialize(stream:JsonDeserializerPluginStream<Int>):Int return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.NUMBER(value):
        cast value;
      case _:
        throw "Expect number";
    }
  }
}

@:final
class UIntDeserializerPlugin
{
  public static function deserialize(stream:JsonDeserializerPluginStream<UInt>):UInt return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.NUMBER(value):
        cast value;
      case _:
        throw "Expect number";
    }
  }
}

#if (java || cs)
  @:final
  class SingleDeserializerPlugin
  {
    public static function deserialize(stream:JsonDeserializerPluginStream<Single>):Single return
    {
      switch (stream.underlying)
      {
        case com.qifun.jsonStream.JsonStream.NUMBER(value):
          value;
        case _:
          throw "Expect number";
      }
    }
  }
#end

@:final
class FloatDeserializerPlugin
{
  public static function deserialize(stream:JsonDeserializerPluginStream<Float>):Float return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.NUMBER(value):
        value;
      case _:
        throw "Expect number";
    }
  }
}

@:final
class BoolDeserializerPlugin
{
  public static function deserialize(stream:JsonDeserializerPluginStream<Bool>):Bool return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.FALSE: false;
      case com.qifun.jsonStream.JsonStream.TRUE: true;
      case _: throw "Expect false | true";
    }
  }
}

@:final
class StringDeserializerPlugin
{
  public static function deserialize(stream:JsonDeserializerPluginStream<String>):String return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.STRING(value):
        value;
      case _:
        throw "Expect string";
    }
  }
}

@:final
class ArrayDeserializerPlugin
{

  @:extern
  public static function getDynamicDeserializerPluginType():Array<Dynamic> return
  {
    throw "Used at compile-time only!";
  }

  public static function deserializeForElement<Element>(stream:JsonDeserializerPluginStream<Array<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Array<Element> return
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
      case _:
        throw "Expect array";
    }
  }
  
  macro public static function deserialize<Element>(stream:ExprOf<JsonDeserializerPluginStream<Array<Element>>>):ExprOf<Array<Element>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.ArrayDeserializerPlugin.deserializeForElement($stream, function(substream) return substream.deserialize());
  }
}

//TODO : StringMap and IntMap
