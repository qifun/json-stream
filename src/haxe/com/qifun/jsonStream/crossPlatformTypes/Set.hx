package com.qifun.jsonStream.crossPlatformTypes;

#if (scala && java && !scala_stm)

import scala.collection.immutable.Set;
abstract Set<A>(scala.collection.immutable.Set<A>)
{
  inline public function new(set:scala.collection.immutable.Set<A>)
  {
    this = set;
  }
}

#elseif cs

import dotnet.system.collections.generic.HashSet;
abstract Set<A>(dotnet.system.collections.generic.HashSet<A>)
{
  inline public function new(hashSet:dotnet.system.collections.generic.HashSet<A>)
  {
    this = hashSet;
  }
}

#elseif (java && scala_stm)

import scala.concurrent.stm.TSet;
abstract Set<A>(scala.concurrent.stm.TSet<A>)
{
  inline public function new(tset:scala.concurrent.stm.TSet<A>)
  {
    this = tset;
  }
}
#end
