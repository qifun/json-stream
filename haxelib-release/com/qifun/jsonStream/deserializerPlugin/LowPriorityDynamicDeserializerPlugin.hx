package com.qifun.jsonStream.deserializerPlugin;

import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.unknown.UnknownType;
#if macro
import haxe.macro.TypeTools;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
#end

/**
  支持生成`Dynamic`类型的反序列化插件。
**/
class LowPriorityDynamicDeserializerPlugin
{

  @:noDynamicDeserialize
  macro public static function pluginDeserialize(
    stream:ExprOf<JsonDeserializerPluginStream<LowPriorityDynamic>>)
    :ExprOf<Null<Dynamic>> return
  {
    switch (Context.follow(Context.typeof(stream)))
    {
      case TAbstract(_, [ expectedType ]):
        JsonDeserializerGenerator.dynamicDeserialize(
          macro $stream.underlying,
          TypeTools.toComplexType(expectedType));
      case _:
        throw "Expected JsonDeserializerPluginStream";
    }
  }

}

