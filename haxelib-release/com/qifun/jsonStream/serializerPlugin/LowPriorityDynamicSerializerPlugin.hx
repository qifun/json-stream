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
  支持生成`Dynamic`类型的序列化插件。
**/
class LowPriorityDynamicSerializerPlugin
{

  @:noDynamicSerialize
  macro public static function pluginSerialize(
    data:ExprOf<JsonSerializerPluginData<LowPriorityDynamic>>)
    :ExprOf<JsonStream> return
  {
    switch (Context.follow(Context.typeof(data)))
    {
      case TAbstract(_, [ expectedType ]):
        JsonSerializerGenerator.dynamicSerialize(
          macro $data.underlying,
          TypeTools.toComplexType(expectedType));
      case _:
        throw "Expected JsonSerializerPluginData";
    }
  }

}

