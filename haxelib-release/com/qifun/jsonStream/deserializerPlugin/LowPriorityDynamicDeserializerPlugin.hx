package com.qifun.jsonStream.deserializerPlugin;

import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.unknown.UnknownType;
import haxe.macro.Expr.ExprOf;
#if macro
import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Type;
#end

/**
  支持生成`Dynamic`类型的反序列化插件。
  
  由于Haxe对`Dynamic`特殊处理，如果直接匹配`Dynamic`，会匹配到其他所有类型。
  使用`LowPriorityDynamic`就只能精确匹配`Dynamic`，所以不会匹配到其他类型。
**/
class LowPriorityDynamicDeserializerPlugin
{

  @:noDynamicDeserialize
  macro public static function pluginDeserialize(stream:ExprOf<JsonDeserializerPluginStream<LowPriorityDynamic>>):ExprOf<Null<Dynamic>> return
  {
    switch (Context.follow(Context.typeof(stream)))
    {
      case TAbstract(_, [ expectedType ]):
        JsonDeserializerBuilder.dynamicDeserialize(macro $stream.underlying, TypeTools.toComplexType(expectedType));
      case _:
        throw "Expected JsonDeserializerPluginStream";
    }
  }

}

