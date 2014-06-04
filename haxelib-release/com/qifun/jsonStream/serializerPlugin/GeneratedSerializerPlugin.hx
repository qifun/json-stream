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
  macro public static function pluginSerialize<T>(stream:ExprOf<JsonSerializerPluginData<T>>):ExprOf<JsonStream> return
  {
    macro throw "TODO";
  }

}

