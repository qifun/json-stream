package ;


class CrossPlatformTypeTest
{

  public static function test()
  {
    showAround();
    typeTest();
  }
  
  private static function typeTest()
  {
    #if (java && scala && !scala_stm)
      var arrayList = new com.qifun.jsonStream.crossPlatformTypes.ArrayList<Dynamic>(scala.collection.immutable.Seq.SeqSingleton.MODULE.empty());
      var set = new com.qifun.jsonStream.crossPlatformTypes.Set<Dynamic>(scala.collection.immutable.Set.SetSingleton.MODULE.empty());
      var map = new com.qifun.jsonStream.crossPlatformTypes.Map<Dynamic, Dynamic>(scala.collection.immutable.Map.MapSingleton.MODULE.empty());
    #elseif cs
      var arrayList = new com.qifun.jsonStream.crossPlatformTypes.ArrayList<Dynamic>(new dotnet.system.collections.generic.List<Dynamic>());
      var set = new com.qifun.jsonStream.crossPlatformTypes.Set<Dynamic>(new dotnet.system.collections.generic.HashSet<Dynamic>());
      var map = new com.qifun.jsonStream.crossPlatformTypes.Map<Dynamic, Dynamic>(new dotnet.system.collections.generic.Dictionary<Dynamic, Dynamic>());
    #elseif (scala_stm && java)
      var arrayList = new com.qifun.jsonStream.crossPlatformTypes.ArrayList<Dynamic>(scala.concurrent.stm.japi.STM.MODULE.newTArray(1).tarray());
      var set = new com.qifun.jsonStream.crossPlatformTypes.Set<Dynamic>(scala.concurrent.stm.japi.STM.MODULE.newTSet().tset());
      var map = new com.qifun.jsonStream.crossPlatformTypes.Map<Dynamic, Dynamic>(scala.concurrent.stm.japi.STM.MODULE.newTMap().tmap());
    #end
  }
  
  private static function showAround()
  {
    #if (java && scala)
      trace("scala around");
    #elseif cs
      trace("cs around");
    #elseif scala_stm
      trace("stm around");
    #end
  }
  
}