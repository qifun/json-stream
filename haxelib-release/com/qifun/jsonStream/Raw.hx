package com.qifun.jsonStream;
import com.dongxiguo.continuation.utils.Generator;

/**
 * @author 杨博
 */
@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":cps"))
@:final
abstract Raw(Dynamic) from Dynamic to Dynamic
{

  @:cps
  @:protected
  private static function iterateJsonObject(instance:Raw, yield:YieldFunction<JsonStream.PairStream>):Void
  {
    for (field in Reflect.fields(instance))
    {
      yield(new JsonStream.PairStream(field, toStream(Reflect.field(instance, field)))).async();
    }
  }

  @:cps
  @:protected
  private static function iterateJsonArray(instance:Array<Raw>, yield:YieldFunction<JsonStream>):Void
  {
    for (element in instance)
    {
      yield(toStream(element)).async();
    }
  }

  /**
    Returns a stream that reads data from `instance`.
  **/
  public static function toStream(instance:Raw):JsonStream
  {
    switch (Type.typeof(instance))
    {
      case TObject:
        return JsonStream.OBJECT(new Generator(iterateJsonObject.bind(instance, _)));
      case TClass(String):
        return JsonStream.STRING(instance);
      case TClass(Array):
        return JsonStream.ARRAY(new Generator(iterateJsonArray.bind(instance, _)));
      case TInt:
        return JsonStream.NUMBER((instance:Dynamic));
      case TFloat:
        return JsonStream.NUMBER((instance:Dynamic));
      case TBool if ((instance:Dynamic)):
        return JsonStream.TRUE;
      case TBool if (!(instance:Dynamic)):
        return JsonStream.FALSE;
      case TNull:
        return JsonStream.NULL;
      case t:
        return throw 'Unsupported instance data: $t';
    }
  }

  /**
    Writes the data in `stream` to a JSON instance, and returns the instance.
  **/
  public static function toRaw(stream:JsonStream):Raw
  {
    switch (stream)
    {
      case JsonStream.OBJECT(entries):
        var object = { };
        for (entry in entries)
        {
          Reflect.setField(object, entry.key, toRaw(entry.value));
        }
        return object;
      case JsonStream.STRING(value):
        return value;
      case JsonStream.ARRAY(elements):
        return [ for (element in elements) toRaw(element) ];
      case JsonStream.NUMBER(value):
        return value;
      case JsonStream.TRUE:
        return true;
      case JsonStream.FALSE:
        return false;
      case JsonStream.NULL:
        return null;
    }
  }
}
