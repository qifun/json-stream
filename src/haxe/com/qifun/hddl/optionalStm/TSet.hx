package com.qifun.hddl.optionalStm;


#if java

abstract TSet<A>(scala.concurrent.stm.TSet<A>)
{
  public inline function new()
  {
    this = scala.concurrent.stm.TSet.TSetSingleton.getInstance().empty();
  }
}

#else

typedef TSet<A> = Map<A, Bool>;

#end

