package com.qifun.jsonStream;

#if macro
  import haxe.macro.Expr;
#end

/**
 * @author 杨博
 */
@:final
class JsonSerializer
{

  macro public static function serialize(data:Expr):ExprOf<JsonStream>
  {
    var serializerSetBuilder = new JsonSerializerSetBuilder();
    var result = serializerSetBuilder.serializeForType(TypeTools.toComplexType(Context.getExpectedType()), data);
    serializerSetBuilder.defineSerializerSet();
    result;
  }
  
}