package com.qifun.jsonStream;

// Default plugins

typedef GeneratedDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.GeneratedDeserializerPlugin;

typedef RawDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.RawDeserializerPlugin;

typedef Int64DeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.Int64DeserializerPlugin;
typedef IntDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.IntDeserializerPlugin;
typedef UIntDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.UIntDeserializerPlugin;
#if (java || cs)
  typedef SingleDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.SingleDeserializerPlugin;
#end
typedef FloatDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.FloatDeserializerPlugin;
typedef BoolDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.BoolDeserializerPlugin;
typedef StringDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.StringDeserializerPlugin;
typedef ArrayDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.ArrayDeserializerPlugin;

typedef UnknownTypeFieldDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.UnknownTypeDeserializerPlugins.UnknownTypeFieldDeserializerPlugin;
typedef UnknownTypeSetterDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.UnknownTypeDeserializerPlugins.UnknownTypeSetterDeserializerPlugin;

typedef LowPriorityDynamicDeserializerPlugin = com.qifun.jsonStream.deserializerPlugin.LowPriorityDynamicDeserializerPlugin;
