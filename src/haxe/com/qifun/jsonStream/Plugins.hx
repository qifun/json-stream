package com.qifun.jsonStream;

// Default plugins

#if doc_gen
/**
  定义了所有内置插件的模块。

  `using com.qifun.jsonStream.Plugins;`将启用`builderPlugin`包、`deserializerPlugin`包和`serializerPlugin`包中的所有插件。
**/
@:final
extern class Plugins{}
#end

@:dox(hide)
typedef GeneratedSerializerPlugin = com.qifun.jsonStream.serializerPlugin.GeneratedSerializerPlugin;

@:dox(hide)
typedef RawSerializerPlugin = com.qifun.jsonStream.serializerPlugin.RawSerializerPlugin;

@:dox(hide)
typedef Int64SerializerPlugin = com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.Int64SerializerPlugin;

@:dox(hide)
typedef UIntSerializerPlugin = com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.UIntSerializerPlugin;

@:dox(hide)
typedef IntSerializerPlugin = com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.IntSerializerPlugin;

#if (java || cs)
  @:dox(hide)
  typedef SingleSerializerPlugin = com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.SingleSerializerPlugin;
#end

@:dox(hide)
typedef FloatSerializerPlugin = com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.FloatSerializerPlugin;

@:dox(hide)
typedef BoolSerializerPlugin = com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.BoolSerializerPlugin;


@:dox(hide)
typedef BinarySerializerPlugin = com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.BinarySerializerPlugin;

@:dox(hide)
typedef StringSerializerPlugin = com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.StringSerializerPlugin;

@:dox(hide)
typedef ArraySerializerPlugin = com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.ArraySerializerPlugin;

@:dox(hide)
typedef VectorSerializerPlugin = com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins.VectorSerializerPlugin;

@:dox(hide)
typedef CrossPlatformRefSerializerPlugin = com.qifun.jsonStream.serializerPlugin.CrossPlatformSerializerPlugins.CrossPlatformRefSerializerPlugin;

@:dox(hide)
typedef CrossPlatformSetSerializerPlugin = com.qifun.jsonStream.serializerPlugin.CrossPlatformSerializerPlugins.CrossPlatformSetSerializerPlugin;

@:dox(hide)
typedef CrossPlatformVectorSerializerPlugin = com.qifun.jsonStream.serializerPlugin.CrossPlatformSerializerPlugins.CrossPlatformVectorSerializerPlugin;

@:dox(hide)
typedef CrossPlatformMapSerializerPlugin = com.qifun.jsonStream.serializerPlugin.CrossPlatformSerializerPlugins.CrossPlatformMapSerializerPlugin;

#if (java && scala)
@:dox(hide)
typedef ScalaSeqSerializerPlugin = com.qifun.jsonStream.serializerPlugin.ScalaSerializerPlugins.ScalaSeqSerializerPlugin;

@:dox(hide)
typedef ScalaSetSerializerPlugin = com.qifun.jsonStream.serializerPlugin.ScalaSerializerPlugins.ScalaSetSerializerPlugin;

@:dox(hide)
typedef ScalaMapSerializerPlugin = com.qifun.jsonStream.serializerPlugin.ScalaSerializerPlugins.ScalaMapSerializerPlugin;

#end

#if cs

@:dox(hide)
typedef CSharpListSerializerPlugin = com.qifun.jsonStream.serializerPlugin.CSharpSerializerPlugins.CSharpListSerializerPlugin;

@:dox(hide)
typedef CSharpDictionarySerializerPlugin = com.qifun.jsonStream.serializerPlugin.CSharpSerializerPlugins.CSharpDictionarySerializerPlugin;

@:dox(hide)
typedef CSharpHashSetSerializerPlugin = com.qifun.jsonStream.serializerPlugin.CSharpSerializerPlugins.CSharpHashSetSerializerPlugin;
#end

#if scala_stm

@:dox(hide)
typedef StmRefSerializerPlugin = com.qifun.jsonStream.serializerPlugin.StmSerializerPlugins.StmRefSerializerPlugin;

@:dox(hide)
typedef StmTSetSerializerPlugin = com.qifun.jsonStream.serializerPlugin.StmSerializerPlugins.StmTSetSerializerPlugin;

@:dox(hide)
typedef StmTMapSerializerPlugin = com.qifun.jsonStream.serializerPlugin.StmSerializerPlugins.StmTMapSerializerPlugin;

@:dox(hide)
typedef StmTArraySerializerPlugin = com.qifun.jsonStream.serializerPlugin.StmSerializerPlugins.StmTArraySerializerPlugin;

#end

@:dox(hide)
typedef LowPriorityDynamicSerializerPlugin = com.qifun.jsonStream.serializerPlugin.LowPriorityDynamicSerializerPlugin;



@:dox(hide)
typedef GeneratedDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.GeneratedDeserializerPlugin;

@:dox(hide)
typedef RawDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.RawDeserializerPlugin;

@:dox(hide)
typedef Int64DeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.Int64DeserializerPlugin;

@:dox(hide)
typedef UIntDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.UIntDeserializerPlugin;

@:dox(hide)
typedef IntDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.IntDeserializerPlugin;

#if (java || cs)
  @:dox(hide)
  typedef SingleDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.SingleDeserializerPlugin;
#end

@:dox(hide)
typedef FloatDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.FloatDeserializerPlugin;

@:dox(hide)
typedef BoolDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.BoolDeserializerPlugin;

@:dox(hide)
typedef BinaryDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.BinaryDeserializerPlugin;

@:dox(hide)
typedef StringDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.StringDeserializerPlugin;

@:dox(hide)
typedef ArrayDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.ArrayDeserializerPlugin;

@:dox(hide)
typedef VectorDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.VectorDeserializerPlugin;

@:dox(hide)
typedef CrossPlatformRefDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformRefDeserializerPlugin;

@:dox(hide)
typedef CrossPlatformVectorDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformVectorDeserializerPlugin;

@:dox(hide)
typedef CrossPlatformMapDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformMapDeserializerPlugin;

@:dox(hide)
typedef CrossPlatformSetDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.CrossPlatformDeserializerPlugins.CrossPlatformSetDeserializerPlugin;

#if (java && scala)
@:dox(hide)
typedef ScalaSeqDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.ScalaDeserializerPlugins.ScalaSeqDeserializerPlugin;

@:dox(hide)
typedef ScalaSetDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.ScalaDeserializerPlugins.ScalaSetDeserializerPlugin;

@:dox(hide)
typedef ScalaMapDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.ScalaDeserializerPlugins.ScalaMapDeserializerPlugin;
#end

#if cs

@:dox(hide)
typedef CSharpListDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.CSharpDeserializerPlugins.CSharpListDeserializerPlugin;

@:dox(hide)
typedef CSharpDictionaryDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.CSharpDeserializerPlugins.CSharpDictionaryDeserializerPlugin;

@:dox(hide)
typedef CSharpHashSetDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.CSharpDeserializerPlugins.CSharpHashSetDeserializerPlugin;

#end

#if scala_stm

@:dox(hide)
typedef StmRefDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.StmDeserializerPlugins.StmRefDeserializerPlugin;

@:dox(hide)
typedef StmTSetDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.StmDeserializerPlugins.StmTSetDeserializerPlugin;

@:dox(hide)
typedef StmTMapDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.StmDeserializerPlugins.StmTMapDeserializerPlugin;

@:dox(hide)
typedef StmTArrayDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.StmDeserializerPlugins.StmTArrayDeserializerPlugin;
#end

@:dox(hide)
typedef LowPriorityDynamicDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.LowPriorityDynamicDeserializerPlugin;




@:dox(hide)
typedef GeneratedBuilderPlugin = com.qifun.jsonStream.builderPlugin.GeneratedBuilderPlugin;

@:dox(hide)
typedef RawBuilderPlugin = com.qifun.jsonStream.builderPlugin.RawBuilderPlugin;

@:dox(hide)
typedef Int64BuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.Int64BuilderPlugin;

@:dox(hide)
typedef UIntBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.UIntBuilderPlugin;

@:dox(hide)
typedef IntBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.IntBuilderPlugin;

#if (java || cs)
  @:dox(hide)
  typedef SingleBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.SingleBuilderPlugin;
#end

@:dox(hide)
typedef FloatBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.FloatBuilderPlugin;

@:dox(hide)
typedef BoolBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.BoolBuilderPlugin;

//TODO Binary builder plugin

@:dox(hide)
typedef StringBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.StringBuilderPlugin;

@:dox(hide)
typedef ArrayBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.ArrayBuilderPlugin;

@:dox(hide)
typedef VectorBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.VectorBuilderPlugin;

@:dox(hide)
typedef LowPriorityDynamicBuilderPlugin = com.qifun.jsonStream.builderPlugin.LowPriorityDynamicBuilderPlugin;

//TODO scala.immutable.Set/Seq build plugin
