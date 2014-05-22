package com.qifun.jsonStream.deserializerPlugin;

import com.qifun.jsonStream.JsonDeserializer;

  
/**
 * @author 杨博
 */
@:final
class RawDeserializerPlugin
{
  
  /**
    Writes the data in `stream` to a JSON instance, and returns the instance.
  **/
  public static function deserialize(stream:TypedJsonStream<RawJson>):RawJson return
  {
    new RawJson(switch (stream.underlying)
    {
      case JsonStream.OBJECT(entries):
        var object = { };
        for (entry in entries)
        {
          Reflect.setField(object, entry.key, deserialize(new TypedJsonStream<RawJson>(entry.value)));
        }
        object;
      case JsonStream.STRING(value):
        value;
      case JsonStream.ARRAY(elements):
        [ for (element in elements) deserialize(new TypedJsonStream<RawJson>(element)) ];
      case JsonStream.NUMBER(value):
        value;
      case JsonStream.TRUE:
        true;
      case JsonStream.FALSE:
        false;
      case JsonStream.NULL:
        null;
    });
  }
  
}