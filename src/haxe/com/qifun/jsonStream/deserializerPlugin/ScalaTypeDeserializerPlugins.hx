package com.qifun.jsonStream.deserializerPlugin;


#if (scala && (java || macro))

import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.ds.Vector;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;
import scala.collection.immutable.Seq;
import scala.collection.immutable.Set;
import scala.collection.immutable.Map;
import scala.Tuple2;
import scala.collection.mutable.Builder;

/**
  ```scala.collection.immutable.Seq```的反序列化插件。
**/
@:final
class SeqScalaDeserializerPlugin
{
  #if java
  @:dox(hide)
  public static function deserializeForElement<Element>(self:JsonDeserializerPluginStream<scala.collection.immutable.Seq<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<scala.collection.immutable.Seq<Element>> return
  {
    switch (self.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(value):
      {
        var seqBuilder = scala.collection.immutable.SeqSingleton.getInstance().newBuilder();
        var generator = Std.instance(value, (Generator:Class<Generator<JsonStream>>));
        if (generator != null)
        {
          for (element in generator)
          {
            seqBuilder.plusEquals(elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
          }
        }
        else
        {
          for (element in value)
          {
            seqBuilder.plusEquals(elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
          }
        }
        seqBuilder.result();
      }
      case NULL:
        null;
      case stream :
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY" , "NULL" ]);
    }
  }
  #end

  #if (java || macro)
  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<scala.collection.immutable.Seq<Element>>>):ExprOf<Null<scala.collection.immutable.Seq<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.ScalaTypeDeserializerPlugins.SeqScalaDeserializerPlugin.deserializeForElement($self, function(substream) return substream.pluginDeserialize());
  }
  #end
}


/**
  ```scala.collection.immutable.Set```的反序列化插件。
**/
@:final
class SetScalaDeserializerPlugin
{
  #if java
  @:dox(hide)
  public static function deserializeForElement<Element>(self:JsonDeserializerPluginStream<scala.collection.immutable.Set<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<scala.collection.immutable.Set<Element>> return
  {
    switch (self.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(value):
      {
        var setBuilder = scala.collection.immutable.SetSingleton.getInstance().newBuilder();
        var generator = Std.instance(value, (Generator:Class<Generator<JsonStream>>));
        if (generator != null)
        {
          for (element in generator)
          {
            setBuilder.plusEquals(elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
          }
        }
        else
        {
          for (element in value)
          {
            setBuilder.plusEquals(elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
          } 
        }
        setBuilder.result();
      }
      case NULL:
        null;
      case stream:
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY" , "NULL" ]);
    }
  }
  #end

  #if (java || macro)
  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<scala.collection.immutable.Set<Element>>>):ExprOf<Null<scala.collection.immutable.Set<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.ScalaTypeDeserializerPlugins.SetScalaDeserializerPlugin.deserializeForElement($self, function(substream) return substream.pluginDeserialize());
  }
  #end
}



/**
  ```scala.collection.immutable.Map```的反序列化插件。
**/
@:final
class MapScalaDeserializerPlugin
{
  #if java
  
  @:dox(hide)
  public static function deserializeForElement<Key, Value>(
    self:JsonDeserializerPluginStream<scala.collection.immutable.Map<Key, Value>>, 
    keyDeserializeFunction:JsonDeserializerPluginStream<Key>->Key, 
    valueDeserializeFunction:JsonDeserializerPluginStream<Value>->Value):
    Null<scala.collection.immutable.Map<Key, Value>> return
  {
    switch (self.underlying)
    {
      case ARRAY(iterator):
      {
        var mapBuilder = scala.collection.immutable.MapSingleton.getInstance().newBuilder();
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
                    mapBuilder.plusEquals(new Tuple2(key, value));
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
                    mapBuilder.plusEquals(new Tuple2(key, value));
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
        mapBuilder.result();
      }
      case NULL:
        null;
      case stream:
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY" , "NULL" ]);
    }
  }
  #end

  #if (java || macro)
  macro public static function pluginDeserialize<Key, Value>(self:ExprOf<JsonDeserializerPluginStream<scala.collection.immutable.Map<Key, Value>>>):ExprOf<Null<scala.collection.immutable.Map<Key, Value>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.ScalaTypeDeserializerPlugins.MapScalaDeserializerPlugin.deserializeForElement($self, function(substream1) return substream1.pluginDeserialize(), function(substream2) return substream2.pluginDeserialize());
  }
  #end
}

#end
