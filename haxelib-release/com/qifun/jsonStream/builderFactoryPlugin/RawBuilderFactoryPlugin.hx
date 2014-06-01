package com.qifun.jsonStream.builderFactoryPlugin;

import com.qifun.jsonStream.JsonBuilderFactory;


class RawBuilderFactoryPlugin
{

  public static function asynchronousDeserializeRaw(stream:JsonBuilderFactoryPluginStream<RawJson>, onComplete:RawJson->Void):Void
  {
    JsonBuilderFactory.asynchronousDeserializeRaw(stream.underlying, onComplete);
  }

}