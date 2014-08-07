package com.qifun.jsonStream.crossPlatformTypes;

#if (scala && java && !scala_stm)

import scala.collection.immutable.Seq;
abstract ArrayList<A>(scala.collection.immutable.Seq<A>)
{
  inline public function new(seq:scala.collection.immutable.Seq<A>)
  {
    this = seq;
  }
}

#elseif cs

import dotnet.system.collections.generic.List;
abstract ArrayList<A>(dotnet.system.collections.generic.List<A>)
{
  inline public function new(list:dotnet.system.collections.generic.List<A>)
  {
    this = list;
  }
}

#elseif (java && scala_stm)

import scala.concurrent.stm.TArray;
abstract ArrayList<A>(scala.concurrent.stm.TArray<A>)
{
  inline public function new(tarray:scala.concurrent.stm.TArray<A>)
  {
    this = tarray;
  }
}
#end
