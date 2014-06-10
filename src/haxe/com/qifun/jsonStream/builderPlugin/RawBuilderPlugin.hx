package com.qifun.jsonStream.builderPlugin;

import com.qifun.jsonStream.JsonBuilderFactory;


class RawBuilderPlugin
{

  public static function pluginBuild(stream:JsonBuilderPluginStream<RawJson>, onComplete:RawJson->Void):Void
  {
    JsonBuilderRuntime.buildRaw(stream.underlying, onComplete);
  }

}