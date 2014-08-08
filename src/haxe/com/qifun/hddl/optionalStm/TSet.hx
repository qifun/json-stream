package com.qifun.hddl.optionalStm;


#if (java && scala_stm)

abstract TSet<A>(scala.concurrent.stm.TSet<A>)
{
  public inline function new()
  {
    this = scala.concurrent.stm.TSet.TSetSingleton.MODULE.empty();
  }
}

#else

typedef TSet<A> = Map<A, Bool>;

#end

