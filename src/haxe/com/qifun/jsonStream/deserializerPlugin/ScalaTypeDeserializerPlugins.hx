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
import scala.BuilderPlusEqualsOperator;

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
          [
            for (element in generator)
            {
              scala.BuilderPlusEqualsOperator.plusEquals(seqBuilder,elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
            }
          ];
        }
        else
        {
          [
            for (element in value)
            {
              scala.BuilderPlusEqualsOperator.plusEquals(seqBuilder,elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
            }
          ];
        }
        seqBuilder.result();
      }
      case NULL:
        null;
      case _:
        throw "Expect Seq";
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
        var seqBuilder = scala.collection.immutable.SetSingleton.getInstance().newBuilder();
        var generator = Std.instance(value, (Generator:Class<Generator<JsonStream>>));
        if (generator != null)
        {
          [
            for (element in generator)
            {
              scala.BuilderPlusEqualsOperator.plusEquals(seqBuilder,elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
            }
          ];
        }
        else
        {
          [
            for (element in value)
            {
              scala.BuilderPlusEqualsOperator.plusEquals(seqBuilder,elementDeserializeFunction(new JsonDeserializerPluginStream(element)));
            }
          ];
        }
        seqBuilder.result();
      }
      case NULL:
        null;
      case _:
        throw "Expect Set";
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

#end
