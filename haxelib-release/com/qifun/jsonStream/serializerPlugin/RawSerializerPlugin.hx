package com.qifun.jsonStream.serializerPlugin;

import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;

@:final
class RawSerializerPlugin
{
  
  /**
    
  **/
  public static function pluginSerialize(data:JsonSerializerPluginData<RawJson>):JsonStream return
  {
    JsonSerializer.serializeRaw(data.underlying);
  }
  
}