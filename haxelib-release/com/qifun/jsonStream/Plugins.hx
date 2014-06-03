package com.qifun.jsonStream;

// Default plugins

#if doc_gen
/**
  定义了所有内置插件的模块。

  `using com.qifun.jsonStream.Plugins;`将启用`deserializerPlugin`包和`serializerPlugin`包中的所有插件。
**/
@:final
extern class Plugins{}
#end

@:dox(hide)
typedef GeneratedDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.GeneratedDeserializerPlugin;

@:dox(hide)
typedef RawDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.RawDeserializerPlugin;

@:dox(hide)
typedef Int64DeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.Int64DeserializerPlugin;

@:dox(hide)
typedef IntDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.IntDeserializerPlugin;

@:dox(hide)
typedef UIntDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.UIntDeserializerPlugin;
#if (java || cs)
  @:dox(hide)
  typedef SingleDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.SingleDeserializerPlugin;
#end

@:dox(hide)
typedef FloatDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.FloatDeserializerPlugin;

@:dox(hide)
typedef BoolDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.BoolDeserializerPlugin;

@:dox(hide)
typedef StringDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.StringDeserializerPlugin;

@:dox(hide)
typedef ArrayDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.ArrayDeserializerPlugin;

@:dox(hide)
typedef LowPriorityDynamicDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.LowPriorityDynamicDeserializerPlugin;




@:dox(hide)
typedef GeneratedBuilderPlugin = com.qifun.jsonStream.builderPlugin.GeneratedBuilderPlugin;

@:dox(hide)
typedef RawBuilderPlugin = com.qifun.jsonStream.builderPlugin.RawBuilderPlugin;

@:dox(hide)
typedef Int64BuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.Int64BuilderPlugin;

@:dox(hide)
typedef IntBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.IntBuilderPlugin;

@:dox(hide)
typedef UIntBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.UIntBuilderPlugin;
#if (java || cs)
  @:dox(hide)
  typedef SingleBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.SingleBuilderPlugin;
#end

@:dox(hide)
typedef FloatBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.FloatBuilderPlugin;

@:dox(hide)
typedef BoolBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.BoolBuilderPlugin;

@:dox(hide)
typedef StringBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.StringBuilderPlugin;

@:dox(hide)
typedef ArrayBuilderPlugin = com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.ArrayBuilderPlugin;

@:dox(hide)
typedef LowPriorityDynamicBuilderPlugin = com.qifun.jsonStream.builderPlugin.LowPriorityDynamicBuilderPlugin;
