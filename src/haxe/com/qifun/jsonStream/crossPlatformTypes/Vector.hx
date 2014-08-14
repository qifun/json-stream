package com.qifun.jsonStream.crossPlatformTypes;

#if (scala && java && scala_stm)
typedef NativeVector<A> = scala.concurrent.stm.TArray<A>;
#else
typedef NativeVector<A> = haxe.ds.Vector<A>;
#end

abstract Vector<A>(NativeVector<A>)
{
  public var underlying(get, never):NativeVector<A>;

  @:extern
  inline function get_underlying():NativeVector<A> return
  {
    this;
  }

  inline public function new(underlying:NativeVector<A>)
  {
    this = underlying;
  }
}
