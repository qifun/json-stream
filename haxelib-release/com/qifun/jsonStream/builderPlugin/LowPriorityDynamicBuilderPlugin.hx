package com.qifun.jsonStream.builderPlugin;

import com.qifun.jsonStream.JsonBuilderFactory;
#if macro
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Type;
#end

/**
  支持生成`Dynamic`类型的反序列化插件。
**/
class LowPriorityDynamicBuilderPlugin
{

  @:noAsynchronousDynamicDeserialize
  macro public static function pluginBuild(
    stream:ExprOf<JsonBuilderPluginStream<LowPriorityDynamic>>,
    onComplete:ExprOf<Dynamic->Void>):ExprOf<Void> return
  {
    switch (Context.follow(Context.typeof(stream)))
    {
      case TAbstract(_, [ expectedType ]):
        JsonBuilderFactoryGenerator.dynamicBuild(
          macro $stream.underlying,
          onComplete,
          TypeTools.toComplexType(expectedType));
      case _:
        throw "Expected JsonBuilderPluginStream";
    }
  }

}

