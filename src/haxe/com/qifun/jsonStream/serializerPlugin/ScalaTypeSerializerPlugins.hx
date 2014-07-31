package com.qifun.jsonStream.serializerPlugin;

#if (scala && (java || macro))

import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import haxe.macro.Context;
import haxe.macro.TypeTools;

/**
  ```scala.collection.Seq```的序列化插件。
**/
@:final
class SeqScalaSerializerPlugin
{
  #if java
  public static function serializeForElement<Element>(self:JsonSerializerPluginData<scala.collection.Seq<Element>>, elementSerializeFunction:JsonSerializerPluginData<Element>->JsonStream):JsonStream return
  {
    if (self.underlying == null)
    {
      NULL;
    }
    else
    {
      ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
      {
        var iterator = scala.collection.Iterator.IteratorSingleton.getInstance().apply(self.underlying);
        while (iterator.hasNext())
        {
          yield(elementSerializeFunction(new JsonSerializerPluginData(iterator.next()))).async();
        }
      })));
    }
  }
  #end

  #if (java || macro)
  macro public static function pluginSerialize<Element>(self:ExprOf<JsonSerializerPluginData<scala.collection.Seq<Element>>>):ExprOf<JsonStream> return
  {
    macro com.qifun.jsonStream.serializerPlugin.ScalaTypeSerializerPlugins.SeqScalaSerializerPlugin.serializeForElement($self, function(subdata) return subdata.pluginSerialize());
  }
  #end
}
#end
