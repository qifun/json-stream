package com.qifun.jsonStream.deserializerPlugin;

import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.ds.Vector;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;

#if (scala && java)
import scala.collection.Seq;
#end

#if scala
/**
```scala.collection.Seq```的反序列化插件。
**/
@:final
class SeqScalaDeserializerPlugin
{
  #if java
  @:dox(hide)
  public static function deserializeForElement<Element>(self:JsonDeserializerPluginStream<Seq<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<Seq<Element>> return
  {
    switch (self.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(value):
      {
        scala.Predef.wrapRefArray(Vector.fromArrayCopy({
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
        })).seq();
      }
      case NULL:
        null;
      case _:
        throw "Expect Seq";
    }
  }
  #end
  
  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<Seq<Element>>>):ExprOf<Null<Seq<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.SeqScalaDeserializerPlugin.deserializeForElement($self, function(substream) return substream.pluginDeserialize());
  }
}
#end