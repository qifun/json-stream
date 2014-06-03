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



// TODO:
//@:dox(hide)
//typedef GeneratedBuilderFactoryPlugin = com.qifun.jsonStream.builderFactoryPlugin.GeneratedBuilderFactoryPlugin;
//
@:dox(hide)
typedef RawBuilderFactoryPlugin = com.qifun.jsonStream.builderFactoryPlugin.RawBuilderFactoryPlugin;

@:dox(hide)
typedef Int64BuilderFactoryPlugin = com.qifun.jsonStream.builderFactoryPlugin.PrimitiveBuilderFactoryPlugins.Int64BuilderFactoryPlugin;

@:dox(hide)
typedef IntBuilderFactoryPlugin = com.qifun.jsonStream.builderFactoryPlugin.PrimitiveBuilderFactoryPlugins.IntBuilderFactoryPlugin;

@:dox(hide)
typedef UIntBuilderFactoryPlugin = com.qifun.jsonStream.builderFactoryPlugin.PrimitiveBuilderFactoryPlugins.UIntBuilderFactoryPlugin;
#if (java || cs)
  @:dox(hide)
  typedef SingleBuilderFactoryPlugin = com.qifun.jsonStream.builderFactoryPlugin.PrimitiveBuilderFactoryPlugins.SingleBuilderFactoryPlugin;
#end

@:dox(hide)
typedef FloatBuilderFactoryPlugin = com.qifun.jsonStream.builderFactoryPlugin.PrimitiveBuilderFactoryPlugins.FloatBuilderFactoryPlugin;

@:dox(hide)
typedef BoolBuilderFactoryPlugin = com.qifun.jsonStream.builderFactoryPlugin.PrimitiveBuilderFactoryPlugins.BoolBuilderFactoryPlugin;

@:dox(hide)
typedef StringBuilderFactoryPlugin = com.qifun.jsonStream.builderFactoryPlugin.PrimitiveBuilderFactoryPlugins.StringBuilderFactoryPlugin;

@:dox(hide)
typedef ArrayBuilderFactoryPlugin = com.qifun.jsonStream.builderFactoryPlugin.PrimitiveBuilderFactoryPlugins.ArrayBuilderFactoryPlugin;

// TODO:
//@:dox(hide)
//typedef LowPriorityDynamicBuilderFactoryPlugin = com.qifun.jsonStream.builderFactoryPlugin.LowPriorityDynamicBuilderFactoryPlugin;
//