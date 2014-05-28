package com.qifun.jsonStream.deserializerPlugin;

import com.qifun.jsonStream.JsonDeserializer;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
#if macro
using Lambda;
import haxe.macro.TypeTools;
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

  /**
   * The fallback deserializeFunction for classes and enums.
   */
  @:noDynamicDeserialize
  macro public static function pluginDeserialize<Element>(stream:ExprOf<JsonDeserializerPluginStream<Element>>):ExprOf<Element> return
  {
    switch (Context.follow(Context.typeof(stream)))
    {
      case TAbstract(_, [ expectedType ]):
        JsonDeserializerBuilder.generatedDeserialize(expectedType, macro $stream.underlying);
      case _:
        throw "Expected JsonDeserializerPluginStream";
    }
  }

}

