package com.qifun.jsonStream.deserializerPlugin;

import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.unknownValue.UnknownType;

/**
 * @author 杨博
 */
class LowPriorityDynamicDeserializerPlugin
{

  @:extern
  public static function getDynamicDeserializerType():NonDynamicDeserializer return
  {
    throw "Used at compile-time only!";
  }
  
  // 由于Haxe对Dynamic特殊处理，如果直接匹配Dynamic，会匹配到其他所有类型
  // 使用LowPriorityDynamic就只能精确匹配Dynamic，所以优先级低于其他能够明确匹配的Deserializer
  macro public static function pluginDeserialize(stream:ExprOf<JsonDeserializerPluginStream<LowPriorityDynamic>>) return
  {
    macro com.qifun.jsonStream.JsonDeserializer.dynamicDeserialize(macro stream.underlying);
  }

  @:extern
  public static inline function pluginDeserializeUnknown<T:LowPriorityDynamic>(stream:JsonDeserializerPluginStream<T>, type:String):Dynamic return
  {
    new com.qifun.jsonStream.unknownValue.UnknownType(type, com.qifun.jsonStream.JsonDeserializer.deserializeRaw(stream.underlying));
  }

}

abstract LowPriorityDynamic(Dynamic) to Dynamic {}
