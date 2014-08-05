package com.qifun.jsonStream.serializerPlugin;

#if (cs || macro)

import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import haxe.macro.Context;
import haxe.macro.TypeTools;
#if cs
import dotnet.system.collections.generic.List;
import dotnet.system.collections.generic.IEnumerator;
import dotnet.system.collections.generic.Dictionary;
import dotnet.system.collections.generic.HashSet;
#end

/**
  ```cs.System.Collection.Generic.List```的序列化插件。
**/
@:final
class CSListSerializerPlugin
{
  #if cs
  public static function serializeForElement<Element>(self:JsonSerializerPluginData<dotnet.system.collections.generic.List<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (self.underlying == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        var enumerator:IEnumerator<Element> = self.underlying.GetEnumerator();
        while(enumerator.MoveNext())
        {
          yield(elementSerializeFunction(new JsonSerializerPluginData(enumerator.Current))).async();
        }
      })));
    }
  }
  #end
  
  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<dotnet.system.collections.generic.List<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.CSharpSerializerPlugins.CSListSerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }

}


/**
  ```cs.System.Collection.Generic.Dictionary```的序列化插件。
**/
  

@:final
class CSDictionarySerializerPlugin
{
  #if cs
  public static function serializeForElement<Key, Value>(
    self:JsonSerializerPluginData<dotnet.system.collections.generic.Dictionary<Key, Value>>, 
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
        var enumerator:IEnumerator<dotnet.system.collections.generic.KeyValuePair<Key, Value>> = self.underlying.GetEnumerator();
        while (enumerator.MoveNext())
        {
          yield(ARRAY(
          new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
          {
            yield(KeySerializeFunction(new JsonSerializerPluginData(enumerator.Current.Key))).async();
            yield(ValueSerializeFunction(new JsonSerializerPluginData(enumerator.Current.Value))).async();
          })))).async();
        }
      })));
    }
  }
  #end

  macro public static function pluginSerialize<Key, Value>(self:ExprOf<JsonSerializerPluginData<dotnet.system.collections.generic.Dictionary<Key, Value>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.CSharpSerializerPlugins.CSDictionarySerializerPlugin.serializeForElement($self, function(subdata1) return subdata1.pluginSerialize(), function(subdata2) return subdata2.pluginSerialize());
  }
}



/**
  ```cs.System.Collection.Generic.HashSet```的序列化插件。
**/
@:final
class CSHashSetSerializerPlugin
{
  #if cs
  public static function serializeForElement<Element>(self:JsonSerializerPluginData<dotnet.system.collections.generic.HashSet<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (self.underlying == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        var enumerator:IEnumerator<Element> = self.underlying.GetEnumerator();
        while(enumerator.MoveNext())
        {
          yield(elementSerializeFunction(new JsonSerializerPluginData(enumerator.Current))).async();
        }
      })));
    }
  }
  #end
  
  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<dotnet.system.collections.generic.HashSet<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.CSharpSerializerPlugins.CSHashSetSerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }

}
#end 