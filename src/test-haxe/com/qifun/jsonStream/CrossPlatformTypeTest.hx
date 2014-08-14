package com.qifun.jsonStream;
import haxe.unit.TestCase;


class CrossPlatformTypeTest extends TestCase
{

  function testType()
  {
    #if (java && scala && !scala_stm)
      var arrayList = new com.qifun.jsonStream.crossPlatformTypes.Vector<Dynamic>(scala.collection.immutable.Seq.SeqSingleton.MODULE.empty());
      var set = new com.qifun.jsonStream.crossPlatformTypes.Set<Dynamic>(scala.collection.immutable.Set.SetSingleton.MODULE.empty());
      var map = new com.qifun.jsonStream.crossPlatformTypes.Map<Dynamic, Dynamic>(scala.collection.immutable.Map.MapSingleton.MODULE.empty());
    #elseif cs
      var arrayList = new com.qifun.jsonStream.crossPlatformTypes.Vector<Dynamic>(new dotnet.system.collections.generic.List<Dynamic>());
      var set = new com.qifun.jsonStream.crossPlatformTypes.Set<Dynamic>(new dotnet.system.collections.generic.HashSet<Dynamic>());
      var map = new com.qifun.jsonStream.crossPlatformTypes.Map<Dynamic, Dynamic>(new dotnet.system.collections.generic.Dictionary<Dynamic, Dynamic>());
    #elseif (scala_stm && java)
      var arrayList = new com.qifun.jsonStream.crossPlatformTypes.Vector<Dynamic>(scala.concurrent.stm.japi.STM.MODULE.newTArray(1).tarray());
      var set = new com.qifun.jsonStream.crossPlatformTypes.Set<Dynamic>(scala.concurrent.stm.japi.STM.MODULE.newTSet().tset());
      var map = new com.qifun.jsonStream.crossPlatformTypes.Map<Dynamic, Dynamic>(scala.concurrent.stm.japi.STM.MODULE.newTMap().tmap());
    #end
  }

}
