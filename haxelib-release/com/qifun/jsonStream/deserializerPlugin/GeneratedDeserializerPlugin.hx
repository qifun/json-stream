package com.qifun.jsonStream.deserializerPlugin;

import com.qifun.jsonStream.JsonDeserializer;
#if macro
import haxe.macro.Expr;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
#end

/**
 * @author 杨博
 */
@:final
class GeneratedDeserializerPlugin
{

  @:extern
  public static function getDynamicDeserializerType():NonDynamicDeserializer return
  {
    throw "Used at compile-time only!";
  }
  
  /**
   * The fallback deserializeFunction for classes and enums.
   */
  macro public static function deserialize<Element>(stream:ExprOf<JsonDeserializerPluginStream<Element>>):ExprOf<Element> return
  {
    var builder = JsonDeserializerSetBuilder.getContextBuilder();
    var expectedType = Context.getExpectedType();
    var methodName = builder.tryAddDeserializeMethod(expectedType);
    if (methodName == null)
    {
      macro
      {
        // 如果加上inline，会导致haxe -java警告
        function(stream:com.qifun.jsonStream.JsonStream):Dynamic return
        {
          switch (stream)
          {
            case OBJECT(pairs):
              switch (com.qifun.jsonStream.IteratorExtractor.optimizedExtract(pairs, 1, function(pair) return currentJsonDeserializerSet().dynamicDeserialize(pair.key, pair.value)))
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
    else
    {
      macro currentJsonDeserializerSet().$methodName($stream.underlying);
    }
  }

}

