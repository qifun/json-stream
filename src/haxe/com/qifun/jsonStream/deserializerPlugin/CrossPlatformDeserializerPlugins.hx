package com.qifun.jsonStream.deserializerPlugin;


import haxe.ds.Vector;
import haxe.macro.*;
import haxe.macro.Expr;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;

@:final
class CrossPlatformSetDeserializerPlugin
{

  @:dox(hide)
  public static inline function toNativeStream<Element>(stream:JsonDeserializerPluginStream<com.qifun.jsonStream.crossPlatformTypes.Set<Element>>) return
  {
    #if (java && scala)
      #if scala_stm
        new JsonDeserializerPluginStream<scala.concurrent.stm.TSet<Element>>(stream.underlying);
      #else
        new JsonDeserializerPluginStream<scala.collection.immutable.Set<Element>>(stream.underlying);
      #end
    #elseif cs
      new JsonDeserializerPluginStream<dotnet.system.collections.generic.HashSet<Element>>(stream.underlying);
    #end
  }

  #if (java || macro)
  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<com.qifun.jsonStream.crossPlatformTypes.Set<Element>>>):ExprOf<Null<com.qifun.jsonStream.crossPlatformTypes.Set<Element>>> return
  {
    if (Context.defined("java") && Context.defined("scala"))
    {
      if (Context.defined("scala_stm"))
      {
        macro
        {
          var nativeStream = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformSetDeserializerPlugin.toNativeStream($self);
          var nativeResult =
            com.qifun.jsonStream.deserializerPlugin.StmDeserializerPlugins.StmTSetDeserializerPlugin.deserializeForElement(
              nativeStream,
              function(substream) return substream.pluginDeserialize());
          new com.qifun.jsonStream.crossPlatformTypes.Set(nativeResult);
        }
      }
      else
      {
        macro
        {
          var nativeStream = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformSetDeserializerPlugin.toNativeStream($self);
          var nativeResult =
            com.qifun.jsonStream.deserializerPlugin.ScalaDeserializerPlugins.ScalaSetDeserializerPlugin.deserializeForElement(
              nativeStream,
              function(substream) return substream.pluginDeserialize());
          new com.qifun.jsonStream.crossPlatformTypes.Set(nativeResult);
        }
      }
    }
    else if (Context.defined("cs"))
    {
      macro
      {
        var nativeStream = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformSetDeserializerPlugin.toNativeStream($self);
        var nativeResult =
          com.qifun.jsonStream.deserializerPlugin.CSharpDeserializerPlugins.CSharpHashSetDeserializerPlugin.deserializeForElement(
            nativeStream,
            function(substream) return substream.pluginDeserialize());
        new com.qifun.jsonStream.crossPlatformTypes.Set(nativeResult);
      }
    }
    else
    {
      Context.error("Unsupported platform", Context.currentPos());
    }
  }
  #end
}


@:final
class CrossPlatformMapDeserializerPlugin
{

  @:dox(hide)
  public static inline function toNativeStream<Key, Value>(stream:JsonDeserializerPluginStream<com.qifun.jsonStream.crossPlatformTypes.Map<Key, Value>>) return
  {
    #if (java && scala)
      #if scala_stm
        new JsonDeserializerPluginStream<scala.concurrent.stm.TMap<Key, Value>>(stream.underlying);
      #else
        new JsonDeserializerPluginStream<scala.collection.immutable.Map<Key, Value>>(stream.underlying);
      #end
    #elseif cs
      new JsonDeserializerPluginStream<dotnet.system.collections.generic.Dictionary<Key, Value>>(stream.underlying);
    #end
  }

  #if (java || macro)
  macro public static function pluginDeserialize<Key, Value>(self:ExprOf<JsonDeserializerPluginStream<com.qifun.jsonStream.crossPlatformTypes.Map<Key, Value>>>):ExprOf<Null<com.qifun.jsonStream.crossPlatformTypes.Map<Key, Value>>> return
  {
    if (Context.defined("java") && Context.defined("scala"))
    {
      if (Context.defined("scala_stm"))
      {
        macro
        {
          var nativeStream = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformMapDeserializerPlugin.toNativeStream($self);
          var nativeResult = com.qifun.jsonStream.deserializerPlugin.StmDeserializerPlugins.StmTMapDeserializerPlugin.deserializeForElement(nativeStream, function(substream) return substream.pluginDeserialize(), function(substream) return substream.pluginDeserialize());
          new com.qifun.jsonStream.crossPlatformTypes.Map(nativeResult);
        }
      }
      else
      {
        macro
        {
          var nativeStream = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformMapDeserializerPlugin.toNativeStream($self);
          var nativeResult = com.qifun.jsonStream.deserializerPlugin.ScalaDeserializerPlugins.ScalaMapDeserializerPlugin.deserializeForElement(nativeStream, function(substream) return substream.pluginDeserialize(), function(substream) return substream.pluginDeserialize());
          new com.qifun.jsonStream.crossPlatformTypes.Map(nativeResult);
        }
      }
    }
    else if (Context.defined("cs"))
    {
      macro
      {
        var nativeStream = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformMapDeserializerPlugin.toNativeStream($self);
        var nativeResult = com.qifun.jsonStream.deserializerPlugin.CSharpDeserializerPlugins.CSharpDictionaryDeserializerPlugin.deserializeForElement(nativeStream, function(substream) return substream.pluginDeserialize(), function(substream) return substream.pluginDeserialize());
        new com.qifun.jsonStream.crossPlatformTypes.Map(nativeResult);
      }
    }
    else
    {
      Context.error("Unsupported platform", Context.currentPos());
    }
  }
  #end
}


@:final
class CrossPlatformVectorDeserializerPlugin
{

  @:dox(hide)
  public static inline function toNativeStream<Element>(stream:JsonDeserializerPluginStream<com.qifun.jsonStream.crossPlatformTypes.Vector<Element>>) return
  {
    #if (java && scala && scala_stm)
      new JsonDeserializerPluginStream<scala.concurrent.stm.TArray<Element>>(stream.underlying);
    #else
      new JsonDeserializerPluginStream<haxe.ds.Vector<Element>>(stream.underlying);
    #end
  }

  #if (java || macro)
  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<com.qifun.jsonStream.crossPlatformTypes.Vector<Element>>>):ExprOf<Null<com.qifun.jsonStream.crossPlatformTypes.Vector<Element>>> return
  {
    if (Context.defined("java") && Context.defined("scala") && Context.defined("scala_stm"))
    {
      macro
      {
        var nativeStream = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformVectorDeserializerPlugin.toNativeStream($self);
        var nativeResult = com.qifun.jsonStream.deserializerPlugin.StmDeserializerPlugins.StmTArrayDeserializerPlugin.deserializeForElement(nativeStream, function(substream) return substream.pluginDeserialize());
        new com.qifun.jsonStream.crossPlatformTypes.Vector(nativeResult);
      }
    }
    else
    {
      macro
      {
        var nativeStream = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformVectorDeserializerPlugin.toNativeStream($self);
        var nativeResult = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.VectorDeserializerPlugin.deserializeForElement(nativeStream, function(substream) return substream.pluginDeserialize());
        new com.qifun.jsonStream.crossPlatformTypes.Vector(nativeResult);
      }
    }
  }
  #end
}
