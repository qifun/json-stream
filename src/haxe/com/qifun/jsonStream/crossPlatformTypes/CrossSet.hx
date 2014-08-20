package com.qifun.jsonStream.crossPlatformTypes;

#if (scala && java)
#if scala_stm
typedef NativeSet<A> = scala.concurrent.stm.TSet<A>;
#else
typedef NativeSet<A> = scala.collection.immutable.Set<A>;
#end
#elseif cs
typedef NativeSet<A> = dotnet.system.collections.generic.HashSet<A>;
#else
import Map in StdMap;
typedef NativeSet<A> = StdMap<A, Bool>;
#end

abstract CrossSet<A>(NativeSet<A>)
{

  public var underlying(get, never):NativeSet<A>;

  @:extern
  inline function get_underlying():NativeSet<A> return
  {
    this;
  }

  inline public function new(set:NativeSet<A>)
  {
    this = set;
  }
}
