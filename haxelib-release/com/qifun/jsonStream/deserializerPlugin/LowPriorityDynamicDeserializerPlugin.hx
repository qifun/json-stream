package com.qifun.jsonStream.deserializerPlugin;

import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.unknownValue.UnknownType;
#if macro
import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Type;
#end
/**
 * @author 杨博
 */
class LowPriorityDynamicDeserializerPlugin
{

  // 由于Haxe对Dynamic特殊处理，如果直接匹配Dynamic，会匹配到其他所有类型
  // 使用LowPriorityDynamic就只能精确匹配Dynamic，所以优先级低于其他能够明确匹配的Deserializer
  @:noDynamicDeserialize
  macro public static function pluginDeserialize(stream:ExprOf<JsonDeserializerPluginStream<LowPriorityDynamic>>) return
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

