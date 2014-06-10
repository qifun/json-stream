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
  支持静态类型的反序列化插件。

  本插件会把所有反序列化操作转发到通过`JsonDeserializer.generateDeserializer`创建的类上。

  由于本插件匹配一切类型，所以比本插件先`using`的插件都会失效。通常应当在`using`其他插件以前`using`本插件。
**/
@:final
class GeneratedDeserializerPlugin
{

  @:noDynamicDeserialize
  macro public static function pluginDeserialize<T>(stream:ExprOf<JsonDeserializerPluginStream<T>>):ExprOf<T> return
  {
    switch (Context.follow(Context.typeof(stream)))
    {
      case TAbstract(_, [ expectedType ]):
        JsonDeserializerGenerator.generatedDeserialize(expectedType, macro $stream.underlying);
      case _:
        throw "Expected JsonDeserializerPluginStream";
    }
  }

}

