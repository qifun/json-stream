package com.qifun.jsonStream.deserializerPlugin;

import com.qifun.jsonStream.JsonDeserializer;

@:final
class RawDeserializerPlugin
{
  
  /**
    Writes the data in `stream` to a JSON instance, and returns the instance.
  **/
  public static function pluginDeserialize(stream:JsonDeserializerPluginStream<RawJson>):Null<RawJson> return
  {
    JsonDeserializer.deserializeRaw(stream.underlying);
  }

  
  
}