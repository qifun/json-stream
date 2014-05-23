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
      macro currentJsonDeserializerSet().dynamicDeserialize($stream.underlying);
    }
    else
    {
      macro currentJsonDeserializerSet().$methodName($stream.underlying);
    }
  }

}

