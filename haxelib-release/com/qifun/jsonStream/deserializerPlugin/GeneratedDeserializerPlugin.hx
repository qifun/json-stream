package com.qifun.jsonStream.deserializerPlugin;

import com.qifun.jsonStream.JsonDeserializer;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

/**
 * @author 杨博
 */
@:final
class GeneratedDeserializerPlugin
{

  @:extern
  public static function getDynamicDeserializerType():NotADynamicTypedDeserializer return
  {
    throw "Used at compile-time only!";
  }
  
  /**
   * The fallback deserializeFunction for classes and enums.
   */
  macro public static function deserialize<Element>(stream:ExprOf<TypedJsonStream<Element>>):ExprOf<Element> return
  {
    var builder = JsonDeserializerSetBuilder.getContextBuilder();
    var methodName = builder.tryAddDeserializeMethod(Context.getExpectedType());
    macro currentJsonDeserializerSet().$methodName($stream.underlying);
  }

}

