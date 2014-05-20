package com.qifun.jsonStream;

import com.dongxiguo.continuation.utils.Generator;

/**
 * @author 杨博
 */
@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":cps"))
@:final
class RawSerializer
{

  @:cps
  @:protected
  private static function iterateJsonObject(instance:Dynamic, yield:YieldFunction<JsonStream.PairStream>):Void
  {
    for (field in Reflect.fields(instance))
    {
      yield(new JsonStream.PairStream(field, serialize(Reflect.field(instance, field)))).async();
    }
  }

  @:cps
  @:protected
  private static function iterateJsonArray(instance:Array<RawJson>, yield:YieldFunction<JsonStream>):Void
  {
    for (element in instance)
    {
      yield(serialize(element)).async();
    }
  }

  /**
    Returns a stream that reads data from `instance`.
  **/
  public static function serialize(instance:RawJson):JsonStream return
  {
    switch (Type.typeof(instance))
    {
      case TObject:
        JsonStream.OBJECT(new Generator(iterateJsonObject.bind(instance.underlying, _)));
      case TClass(String):
        JsonStream.STRING(instance.underlying);
      case TClass(Array):
        JsonStream.ARRAY(new Generator(iterateJsonArray.bind(instance.underlying, _)));
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