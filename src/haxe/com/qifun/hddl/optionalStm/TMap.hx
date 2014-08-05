package com.qifun.hddl.optionalStm;


#if java

abstract TMap<A, B>(scala.concurrent.stm.TMap<A, B>)
{
  public inline function new()
  {
    this = scala.concurrent.stm.TMap.TMapSingleton.MODULE.empty();
  }
}

#else

typedef TMap<A, B> = Map<A, B>;

#end

