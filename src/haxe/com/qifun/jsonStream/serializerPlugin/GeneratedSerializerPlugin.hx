package com.qifun.jsonStream.serializerPlugin;

import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.unknown.UnknownType;
import haxe.macro.Expr.ExprOf;
#if macro
import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Type;
#end

/**
  支持静态类型的序列化插件。

  本插件会把所有序列化操作转发到通过`JsonSerializer.generateSerializer`创建的类上。

  由于本插件匹配一切类型，所以比本插件先`using`的插件都会失效。通常应当在`using`其他插件以前`using`本插件。
**/
class GeneratedSerializerPlugin
{

  @:noDynamicSerialize
  macro public static function pluginSerialize<T>(
    data:ExprOf<JsonSerializerPluginData<T>>):ExprOf<JsonStream> return
  {
    switch (Context.follow(Context.typeof(data)))
    {
      case TAbstract(_, [ expectedType ]):
        JsonSerializerGenerator.generatedSerialize(
          macro $data.underlying,
          expectedType);
      case _:
        throw "Expected JsonSerializerPluginData";
    }
  }

}

