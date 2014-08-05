package com.qifun.jsonStream.serializerPlugin;



#if (scala_stm && (java || macro))
import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import haxe.macro.Context;
import haxe.macro.TypeTools;
import scala.concurrent.stm.Ref;
import scala.concurrent.stm.TSet;
import scala.concurrent.stm.TMap;

@:final
class STMRefSerializerPlugin
{
  #if java
  public static function serializeForElement<Element>(self:JsonSerializerPluginData<scala.concurrent.stm.Ref<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (self.underlying == null)
    {
      NULL;
    }
    else
    {
      var i = self.underlying.single().get();
      elementSerializeFunction(new JsonSerializerPluginData(i));
    }
  }
  #end

  #if (java || macro)
  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<scala.concurrent.stm.Ref<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.STMSerializerPlugins.STMRefSerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }
  #end
}

@:final
class STMTSetSerializerPlugin
{
  #if java
  public static function serializeForElement<Element>(self:JsonSerializerPluginData<scala.concurrent.stm.TSet<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (self.underlying == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        var iterator = self.underlying.single().iterator();
        while (iterator.hasNext())
        {
          yield(elementSerializeFunction(new JsonSerializerPluginData(iterator.next()))).async();
        }
      })));
    }
  }
  #end

  #if (java || macro)
  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<scala.concurrent.stm.TSet<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.STMSerializerPlugins.STMTSetSerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }
  #end
}


class STMTMapSerializerPlugin
{
  #if java
  public static function serializeForElement<Key, Value>(
    self:JsonSerializerPluginData<scala.concurrent.stm.TMap<Key, Value>>, 
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
        var iterator = self.underlying.single().iterator();
        while (iterator.hasNext())
        {
          yield(ARRAY(
          new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
          {
            var element = iterator.next();
            yield(KeySerializeFunction(new JsonSerializerPluginData(element._1))).async();
            yield(ValueSerializeFunction(new JsonSerializerPluginData(element._2))).async();
          })))).async();
        }
      })));
    }
  }
  #end

  #if (java || macro)
  macro public static function pluginSerialize<Key, Value>(self:ExprOf<JsonSerializerPluginData<scala.concurrent.stm.TMap<Key, Value>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.STMSerializerPlugins.STMTMapSerializerPlugin.serializeForElement($self, function(subdata1) return subdata1.pluginSerialize(), function(subdata2) return subdata2.pluginSerialize());
  }
  #end
}

#end