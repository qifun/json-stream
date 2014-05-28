package com.qifun.jsonStream;

import com.dongxiguo.continuation.utils.Generator;

/**
 * @author 杨博
 */
@:final
class RawSerializer
{

  private static function iterateJsonObject(instance:Dynamic) return
  {
    com.dongxiguo.continuation.Continuation.cpsFunction(function(yield:YieldFunction<JsonStream.PairStream>):Void
    {
      for (field in Reflect.fields(instance))
      {
        yield(new JsonStream.PairStream(field, serializeRaw(Reflect.field(instance, field)))).async();
      }
    });
  }
  
  private static function iterateJsonArray(instance:Array<RawJson>) return
  {
    com.dongxiguo.continuation.Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
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
  
}