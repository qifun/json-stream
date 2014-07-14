package com.qifun.jsonStream.builderPlugin;

import com.qifun.jsonStream.JsonBuilderFactory;


class RawBuilderPlugin
{

  public static function pluginBuild(self:JsonBuilderPluginStream<RawJson>, onComplete:RawJson->Void):Void
  {
    JsonBuilderRuntime.buildRaw(self.underlying, onComplete);
  }

}
