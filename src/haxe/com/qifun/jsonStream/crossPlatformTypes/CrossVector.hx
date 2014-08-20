package com.qifun.jsonStream.crossPlatformTypes;

#if (scala && java && scala_stm)
typedef NativeVector<A> = scala.concurrent.stm.TArray<A>;
#else
typedef NativeVector<A> = haxe.ds.Vector<A>;
#end
/**
  因为haxe的bug，值类型，如```Int```、```Double```等在java以及scala平台无法编译通过
**/
abstract CrossVector<A>(NativeVector<A>)
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
