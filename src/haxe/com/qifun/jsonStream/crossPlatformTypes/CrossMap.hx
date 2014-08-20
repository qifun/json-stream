package com.qifun.jsonStream.crossPlatformTypes;

#if (scala && java)
#if scala_stm
typedef NativeMap<A, B> = scala.concurrent.stm.TMap<A, B>;
#else
typedef NativeMap<A, B> = scala.collection.immutable.Map<A, B>;
#end
#elseif cs
typedef NativeMap<A, B> = dotnet.system.collections.generic.Dictionary<A, B>;
#else
import Map in StdMap;
typedef NativeMap<A, B> = StdMap<A, B>;
#end

abstract CrossMap<A, B>(NativeMap<A, B>)
{

  public var underlying(get, never):NativeMap<A, B>;

  @:extern
  inline function get_underlying():NativeMap<A, B> return
  {
    this;
  }

  inline public function new(map:NativeMap<A, B>)
  {
    this = map;
  }

}
