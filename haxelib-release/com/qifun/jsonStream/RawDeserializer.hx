package com.qifun.jsonStream;

/**
 * ...
 * @author 杨博
 */
@:final
class RawDeserializer
{

  
  /**
    Writes the data in `stream` to a JSON instance, and returns the instance.
  **/
  public static function deserialize(stream:JsonStream):RawJson return
  {
    new RawJson(switch (stream)
    {
      case JsonStream.OBJECT(entries):
        var object = { };
        for (entry in entries)
        {
          Reflect.setField(object, entry.key, deserialize(entry.value));
        }
        object;
      case JsonStream.STRING(value):
        value;
      case JsonStream.ARRAY(elements):
        [ for (element in elements) deserialize(element) ];
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