package com.qifun.jsonStream.crossPlatformTypes;

#if (scala && java)
#if scala_stm
typedef NativeRef<A> = scala.concurrent.stm.Ref<A>;
#else
typedef NativeRef<A> = A;
#end
#elseif cs
typedef NativeRef<A> = A;
#else
typedef NativeRef<A> = A;
#end

abstract Ref<A>(NativeRef<A>)
{

  public var underlying(get, never):NativeRef<A>;

  @:extern
  inline function get_underlying():NativeRef<A> return
  {
    this;
  }

  inline public function new(ref:NativeRef<A>)
  {
    this = ref;
  }
}
