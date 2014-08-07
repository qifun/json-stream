package com.qifun.jsonStream.crossPlatformTypes;

#if (scala && java && !scala_stm)

import scala.collection.immutable.Map;
abstract Map<A, B>(scala.collection.immutable.Map<A, B>)
{
  inline public function new(map:scala.collection.immutable.Map<A, B>)
  {
    this = map;
  }
}

#elseif cs

import dotnet.system.collections.generic.Dictionary;
abstract Map<A, B>(dotnet.system.collections.generic.Dictionary<A, B>)
{
  inline public function new(dictionary:dotnet.system.collections.generic.Dictionary<A, B>)
  {
    this = dictionary;
  }
}

#elseif (java && scala_stm)

import scala.concurrent.stm.TMap;
abstract Map<A, B>(scala.concurrent.stm.TMap<A, B>)
{
  inline public function new(tmap:scala.concurrent.stm.TMap<A, B>)
  {
    this = tmap;
  }
}
#end
