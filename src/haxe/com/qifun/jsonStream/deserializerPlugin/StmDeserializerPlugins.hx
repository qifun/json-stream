package com.qifun.jsonStream.deserializerPlugin;



#if (scala_stm && (java || macro))
import scala.concurrent.stm.Ref;
import scala.concurrent.stm.RefView;
import scala.concurrent.stm.TSet;
import scala.concurrent.stm.TMap;
import scala.concurrent.stm.TArray;
import scala.concurrent.stm.TArrayView;
import scala.concurrent.stm.japi.STM;
import scala.Tuple2;
import haxe.macro.Context;
import haxe.macro.TypeTools;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;

@:final
class StmRefDeserializerPlugin
{
  #if java
  @:dox(hide)
  public static function deserializeForElement<Element>(self:JsonDeserializerPluginStream<scala.concurrent.stm.Ref<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<scala.concurrent.stm.Ref<Element>> return
  {
    switch (self.underlying)
    {
      case NULL:
      {
        null;
      }
      case stream:
      {
        var refView:RefView<Element> = STM.MODULE.newRef(elementDeserializeFunction(new JsonDeserializerPluginStream(self.underlying)));
        refView.ref();
      }
    }
  }
  #end

  #if (java || macro)
  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<scala.concurrent.stm.Ref<Element>>>):ExprOf<Null<scala.concurrent.stm.Ref<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.StmDeserializerPlugins.StmRefDeserializerPlugin.deserializeForElement($self, function(substream) return substream.pluginDeserialize());
  }
  #end
}

@:final
class StmTSetDeserializerPlugin
{
  #if java
  @:dox(hide)
  public static function deserializeForElement<Element>(self:JsonDeserializerPluginStream<scala.concurrent.stm.TSet<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<scala.concurrent.stm.TSet<Element>> return
  {
    switch (self.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(value):
      {
        var setBuilder = scala.concurrent.stm.TSetSingleton.MODULE.newBuilder();
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
  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<scala.concurrent.stm.TSet<Element>>>):ExprOf<Null<scala.concurrent.stm.TSet<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.StmDeserializerPlugins.StmTSetDeserializerPlugin.deserializeForElement($self, function(substream) return substream.pluginDeserialize());
  }
  #end
}

@:final
class StmTArrayDeserializerPlugin
{
  #if java
  @:dox(hide)
  public static function deserializeForElement<Element>(self:JsonDeserializerPluginStream<scala.concurrent.stm.TArray<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<scala.concurrent.stm.TArray<Element>> return
  {
    switch (self.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(value):
      {
        var array:Array<Element> = [];
        var generator = Std.instance(value, (Generator:Class<Generator<JsonStream>>));
        if (generator != null)
        {
          for (element in generator)
          {
            array.push(elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
          }
        }
        else
        {
          for (element in value)
          {
            array.push(elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
          } 
        }
        var tarrayView:TArrayView<Element> = STM.MODULE.newTArray(array.length);
        var i:Int = -1;
        while (++i < array.length)
        {
          tarrayView.update(i, array[i]);
        }
        tarrayView.tarray();
      }
      case NULL:
        null;
      case stream:
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY" , "NULL" ]);
    }
  }
  #end

  #if (java || macro)
  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<scala.concurrent.stm.TArray<Element>>>):ExprOf<Null<scala.concurrent.stm.TArray<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.StmDeserializerPlugins.StmTArrayDeserializerPlugin.deserializeForElement($self, function(substream) return substream.pluginDeserialize());
  }
  #end
}

@:final
class StmTMapDeserializerPlugin
{
  #if java
  
  @:dox(hide)
  public static function deserializeForElement<Key, Value>(
    self:JsonDeserializerPluginStream<scala.concurrent.stm.TMap<Key, Value>>, 
    keyDeserializeFunction:JsonDeserializerPluginStream<Key>->Key, 
    valueDeserializeFunction:JsonDeserializerPluginStream<Value>->Value):
    Null<scala.concurrent.stm.TMap<Key, Value>> return
  {
    switch (self.underlying)
    {
      case ARRAY(iterator):
      {
        var mapBuilder = scala.concurrent.stm.TMapSingleton.MODULE.newBuilder();
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
  macro public static function pluginDeserialize<Key, Value>(self:ExprOf<JsonDeserializerPluginStream<scala.concurrent.stm.TMap<Key, Value>>>):ExprOf<Null<scala.concurrent.stm.TMap<Key, Value>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.StmDeserializerPlugins.StmTMapDeserializerPlugin.deserializeForElement($self, function(substream1) return substream1.pluginDeserialize(), function(substream2) return substream2.pluginDeserialize());
  }
  #end
}

#end