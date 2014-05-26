package com.qifun.jsonStream.deserializerPlugin;

import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonStream;

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
  macro public static function pluginDeserialize(stream:ExprOf<JsonDeserializerPluginStream<LowPriorityDynamic>>):ExprOf<Dynamic> return
  {
    macro
    {
      function(stream:com.qifun.jsonStream.JsonStream):Dynamic return
      {
        switch (stream)
        {
          case OBJECT(pairs):
            switch (
              com.qifun.jsonStream.IteratorExtractor.optimizedExtract1(
                pairs,
                com.qifun.jsonStream.IteratorExtractor.identity,
                com.qifun.jsonStream.IteratorExtractor.identity,
                function(pair) return currentJsonDeserializerSet().dynamicDeserialize(pair.key, pair.value)))
            {
              case null: JsonDeserializer.deserializeRaw(stream);
              case notNull: notNull;
            }
          case NULL:
            null;
          case _:
            throw "Expect object!";
        }
      }($stream.underlying);
    }
  }

}

abstract LowPriorityDynamic(Dynamic) to Dynamic {}
