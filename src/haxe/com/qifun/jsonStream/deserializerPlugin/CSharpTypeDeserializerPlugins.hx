package com.qifun.jsonStream.deserializerPlugin;

#if cs

import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.ds.Vector;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;
import haxe.macro.Context;
import haxe.macro.TypeTools;
import cs.system.collections.generic.List_1;
import cs.system.collections.generic.SortedDictionary_2;
/**
  ```cs.System.Collection.Generic.List```的序列化插件。
**/
@:final
class ListCSDeserializerPlugin
{
  @:dox(hide)
  public static function deserializeForElement<Element>(self:JsonDeserializerPluginStream<cs.system.collections.generic.List_1<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<cs.system.collections.generic.List_1<Element>> return
  {
    switch (self.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(value):
      {
        var list = new cs.system.collections.generic.List_1<Element>();
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

  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<cs.system.collections.generic.List_1<Element>>>):ExprOf<Null<cs.system.collections.generic.List_1<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.CSharpTypeDeserializerPlugins.ListCSDeserializerPlugin.deserializeForElement($self, function(substream) return substream.pluginDeserialize());
  }
}


/**
  ```cs.System.Collection.Generic.SortedDictionary```的序列化插件。
**/
@:final
class SortedDictionaryCSDeserializerPlugin
{
  
  @:dox(hide)
  public static function deserializeForElement<Key, Value>(
    self:JsonDeserializerPluginStream<cs.system.collections.generic.SortedDictionary_2<Key, Value>>, 
    keyDeserializeFunction:JsonDeserializerPluginStream<Key>->Key, 
    valueDeserializeFunction:JsonDeserializerPluginStream<Value>->Value):
    Null<cs.system.collections.generic.SortedDictionary_2<Key, Value>> return
  {
    switch (self.underlying)
    {
      case ARRAY(iterator):
      {
        var dictionary = new cs.system.collections.generic.SortedDictionary_2<Key, Value>();
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

  macro public static function pluginDeserialize<Key, Value>(self:ExprOf<JsonDeserializerPluginStream<cs.system.collections.generic.SortedDictionary_2<Key, Value>>>):ExprOf<Null<cs.system.collections.generic.SortedDictionary_2<Key, Value>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.CsharpTypeDeserializerPlugins.SortedDictionaryCSDeserializerPlugin.deserializeForElement($self, function(substream1) return substream1.pluginDeserialize(), function(substream2) return substream2.pluginDeserialize());
  }
}
#end