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
  public static function pluginDeserialize(stream:JsonDeserializerPluginStream<RawJson>):RawJson return
  {
    JsonDeserializer.deserializeRaw(stream.underlying);
  }

  
  
}