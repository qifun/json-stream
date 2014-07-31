package com.qifun.jsonStream.serializerPlugin;

import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;

@:final
class RawSerializerPlugin
{

  /**

  **/
  @:noDynamicSerialize
  public static function pluginSerialize(self:JsonSerializerPluginData<RawJson>):JsonStream return
  {
    JsonSerializer.serializeRaw(self.underlying);
  }

}
