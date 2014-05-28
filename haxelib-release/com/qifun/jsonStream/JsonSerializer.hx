package com.qifun.jsonStream;

import com.dongxiguo.continuation.utils.Generator;
import com.dongxiguo.continuation.Continuation;
import com.qifun.jsonStream.JsonStream;
#if macro
  import haxe.macro.Expr;
#end

/**
 * @author 杨博
 */
@:final
class JsonSerializer
{

  private static function iterateJsonObject(instance:Dynamic) return
  {
    Continuation.cpsFunction(function(yield:YieldFunction<JsonStreamPair>):Void
    {
      for (field in Reflect.fields(instance))
      {
        yield(new JsonStream.JsonStreamPair(field, serializeRaw(Reflect.field(instance, field)))).async();
      }
    });
  }
  
  private static function iterateJsonArray(instance:Array<RawJson>) return
  {
    Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
    {
      for (element in instance)
      {
        yield(serializeRaw(element)).async();
      }
    });
  }

  /**
    Returns a stream that reads data from `instance`.
  **/
  public static function serializeRaw(instance:RawJson):JsonStream return
  {
    switch (Type.typeof(instance.underlying))
    {
      case TObject:
        JsonStream.OBJECT(new Generator(iterateJsonObject(instance.underlying)));
      case TClass(String):
        JsonStream.STRING(instance.underlying);
      case TClass(Array):
        JsonStream.ARRAY(new Generator(iterateJsonArray(instance.underlying)));
      case TInt:
        JsonStream.NUMBER((instance:Dynamic));
      case TFloat:
        JsonStream.NUMBER((instance:Dynamic));
      case TBool if ((instance:Dynamic)):
        JsonStream.TRUE;
      case TBool if (!(instance:Dynamic)):
        JsonStream.FALSE;
      case TNull:
        JsonStream.NULL;
      case t:
        throw 'Unsupported instance data: $t';
    }
  }
  
  macro public static function serialize(data:Expr):ExprOf<JsonStream>
  {
    macro $data.pluginSerialize();
  }
  
}


/**
 * Internal type for deserializer plugins.
 * 避免污染上下文代码提示列表
 * @author 杨博
 */
abstract JsonSerializerPluginData<ResultType>(ResultType)
{

  @:extern
  public inline function new(underlying:ResultType) 
  {
    this = underlying;
  }
  
  public var underlying(get, never):ResultType;
  
  @:extern
  inline function get_underlying():ResultType return
  {
    this;
  }
  
}