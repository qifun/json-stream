package com.qifun.jsonStream.deserializerPlugin;

import com.qifun.jsonStream.JsonDeserializer;

/**
 * @author 杨博
 */
class LowPriorityDynamicDeserializerPlugin
{

  // 由于Haxe对Dynamic特殊处理，如果直接匹配Dynamic，会匹配到其他所有类型
  // 使用LowPriorityDynamic就只能精确匹配Dynamic，所以优先级低于其他能够明确匹配的Deserializer
  macro public static function deserialize(stream:ExprOf<TypedJsonStream<LowPriorityDynamic>>):ExprOf<Dynamic> return
  {
    var builder = JsonDeserializerSetBuilder.getContextBuilder();
    macro currentJsonDeserializerSet().dynamicDeserialize($stream.underlying);
  }

}

abstract LowPriorityDynamic(Dynamic) to Dynamic {}
