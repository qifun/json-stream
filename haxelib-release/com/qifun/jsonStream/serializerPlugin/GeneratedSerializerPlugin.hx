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

