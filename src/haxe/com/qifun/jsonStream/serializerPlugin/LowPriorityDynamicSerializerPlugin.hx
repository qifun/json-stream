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
  支持序列化`Dynamic`类型的插件。
**/
class LowPriorityDynamicSerializerPlugin
{

  @:noDynamicSerialize
  macro public static function pluginSerialize(
    self:ExprOf<JsonSerializerPluginData<LowPriorityDynamic>>):ExprOf<JsonStream> return
  {
    switch (Context.follow(Context.typeof(self)))
    {
      case TAbstract(_, [ expectedType ]):
        JsonSerializerGenerator.dynamicSerialize(
          macro $self.underlying,
          TypeTools.toComplexType(expectedType));
      case _:
        throw "Expected JsonSerializerPluginData";
    }
  }

}

