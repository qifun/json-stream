package com.qifun.jsonStream.serializerPlugin;

#if cs

import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import haxe.macro.Context;
import haxe.macro.TypeTools;
import cs.system.collections.generic.List_1;
import cs.system.collections.generic.SortedDictionary_2;


/**
  ```cs.System.Collection.Generic.List```的序列化插件。
**/
@:final
class ListCSSerializerPlugin
{
  public static function serializeForElement<Element>(self:JsonSerializerPluginData<cs.system.collections.generic.List_1<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (self.underlying == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        var iterator = self.underlying.GetEnumerator();
        while(iterator.MoveNext())
        {
          yield(elementSerializeFunction(new JsonSerializerPluginData(iterator.Current))).async();
        }
      })));
    }
  }

  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<cs.system.collections.generic.List_1<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.CSharpTypeSerializerPlugins.ListCSSerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }

}


/**
  ```cs.System.Collection.Generic.SortedDictionary```的序列化插件。
**/
  

@:final
class SortedDictionaryCSSerializerPlugin
{
  public static function serializeForElement<Key, Value>(
    self:JsonSerializerPluginData<cs.system.collections.generic.SortedDictionary_2<Key, Value>>, 
    KeySerializeFunction:JsonSerializerPluginData<Key>->JsonStream, 
    ValueSerializeFunction:JsonSerializerPluginData<Value>->JsonStream):JsonStream return
  {
    if (self.underlying == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        var iterator = self.underlying.GetEnumerator();
        while (iterator.MoveNext())
        {
          yield(ARRAY(
          new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
          {
            yield(KeySerializeFunction(new JsonSerializerPluginData(iterator.Current.Key))).async();
            yield(ValueSerializeFunction(new JsonSerializerPluginData(iterator.Current.Value))).async();
          })))).async();
        }
      })));
    }
  }


  macro public static function pluginSerialize<Key, Value>(self:ExprOf<JsonSerializerPluginData<cs.system.collections.generic.SortedDictionary_2<Key, Value>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.CSharpTypeSerializerPlugins.SortedDictionaryCSSerializerPlugin.serializeForElement($self, function(subdata1) return subdata1.pluginSerialize(), function(subdata2) return subdata2.pluginSerialize());
  }
}

#end 