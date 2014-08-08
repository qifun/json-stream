package com.qifun.jsonStream;

using com.qifun.jsonStream.MacroTest;
import com.dongxiguo.continuation.utils.Generator;
import com.dongxiguo.continuation.Continuation;
import com.qifun.jsonStream.io.PrettyTextPrinter;
import haxe.io.BytesOutput;
using com.qifun.jsonStream.Plugins;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;

class AbstructTypePluginTest extends JsonTestCase
{
  function testAbstructTypeSerializerPlugins()
  {
    var o = new AbstructTypeTest();
    #if (java && scala_stm)
      var setBuilder:scala.collection.mutable.Builder<Int, scala.concurrent.stm.TSet<Int>> = scala.concurrent.stm.TSet.TSetSingleton.MODULE.newBuilder();
      setBuilder.plusEquals(30);
      setBuilder.plusEquals(82);
      setBuilder.plusEquals(255);
      setBuilder.plusEquals(4099);
      setBuilder.plusEquals(96354);
      o.set = new com.qifun.jsonStream.crossPlatformTypes.Set(setBuilder.result());
      
      var tarrayView:scala.concurrent.stm.TArrayView<Int> = scala.concurrent.stm.japi.STM.MODULE.newTArray(5);
      tarrayView.update(0, 1);
      tarrayView.update(1, 1);
      tarrayView.update(2, 2);
      tarrayView.update(3, 3);
      tarrayView.update(4, 5);
      o.list = new com.qifun.jsonStream.crossPlatformTypes.ArrayList(tarrayView.tarray());

      var mapBuilder:scala.collection.mutable.Builder<scala.Tuple2<Int, Int>, scala.concurrent.stm.TMap<Int, Int>> = scala.concurrent.stm.TMap.TMapSingleton.MODULE.newBuilder();
      mapBuilder.plusEquals(new scala.Tuple2(42, 1764));
      mapBuilder.plusEquals(new scala.Tuple2(14, 169));
      mapBuilder.plusEquals(new scala.Tuple2(25, 625));
      mapBuilder.plusEquals(new scala.Tuple2(256, 65536));
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(mapBuilder.result());
    #elseif cs
      var set = new dotnet.system.collections.generic.HashSet;
      set.Add(30);
      set.Add(82);
      set.Add(255);
      set.Add(4099);
      set.Add(96354);
      o.set = new com.qifun.jsonStream.crossPlatformTypes.Set(set);
      
      var list = new dotnet.system.collections.generic.List;
      list.Add(1);
      list.Add(1);
      list.Add(2);
      list.Add(3);
      list.Add(5);
      o.list = new com.qifun.jsonStream.crossPlatformTypes.ArrayList(list);
      
      var map = new dotnet.system.collections.generic.Dictionary;
      map.Add(42, 1764);
      map.Add(14, 169);
      map.Add(25, 625);
      map.Add(256, 65536);
      o.map = new com.qifun.jsonStream.crossPlatformTypes.ArrayList(map);
      
    #elseif (java && scala && !scala_stm)
      var setBuilder:scala.collection.mutable.Builder<Int, Dynamic> = scala.collection.immutable.Set.SetSingleton.MODULE.newBuilder();
      setBuilder.plusEquals(30);
      setBuilder.plusEquals(82);
      setBuilder.plusEquals(255);
      setBuilder.plusEquals(4099);
      setBuilder.plusEquals(96354);
      o.set = new com.qifun.jsonStream.crossPlatformTypes.Set(setBuilder.result());
      
      var seqBuilder:scala.collection.mutable.Builder<Int, Dynamic> = scala.collection.immutable.Seq.SeqSingleton.MODULE.newBuilder();
      seqBuilder.plusEquals(1);
      seqBuilder.plusEquals(1);
      seqBuilder.plusEquals(2);
      seqBuilder.plusEquals(3);
      seqBuilder.plusEquals(5);
      o.list = new com.qifun.jsonStream.crossPlatformTypes.ArrayList(seqBuilder.result());

      var mapBuilder:scala.collection.mutable.Builder<scala.Tuple2<Int, Int>, Dynamic> = scala.collection.immutable.Map.MapSingleton.MODULE.newBuilder();
      mapBuilder.plusEquals(new scala.Tuple2(42, 1764));
      mapBuilder.plusEquals(new scala.Tuple2(14, 169));
      mapBuilder.plusEquals(new scala.Tuple2(25, 625));
      mapBuilder.plusEquals(new scala.Tuple2(256, 65536));
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(mapBuilder.result());
    #end  
    
    var jsonStream = JsonSerializer.serialize(o);
    assertDeepEquals( 
    {list:[ { Int:1 }, { Int:1 }, { Int:2 }, { Int:3 }, { Int:5 } ],
     map:[[ { Int:14 }, { Int:169 } ], [ { Int:25 }, { Int:625 } ], [ { Int:42 }, { Int:1764 } ], 
     [ { Int:256 }, { Int:65536 } ]], set : [ { Int : 30 }, { Int : 82 }, { Int : 255 }, { Int : 4099 }, { Int : 96354 } ] }
    , JsonDeserializer.deserializeRaw(jsonStream));
  }
  
  function testAbstructTypeDeseralizerPlugins()
  {
    var o = new AbstructTypeTest();
    #if (java && scala_stm)
      var setBuilder:scala.collection.mutable.Builder<Int, scala.concurrent.stm.TSet<Int>> = scala.concurrent.stm.TSet.TSetSingleton.MODULE.newBuilder();
      setBuilder.plusEquals(30);
      setBuilder.plusEquals(82);
      setBuilder.plusEquals(255);
      setBuilder.plusEquals(4099);
      setBuilder.plusEquals(96354);
      o.set = new com.qifun.jsonStream.crossPlatformTypes.Set(setBuilder.result());
      
      var tarrayView:scala.concurrent.stm.TArrayView<Int> = scala.concurrent.stm.japi.STM.MODULE.newTArray(5);
      tarrayView.update(0, 1);
      tarrayView.update(1, 1);
      tarrayView.update(2, 2);
      tarrayView.update(3, 3);
      tarrayView.update(4, 5);
      o.list = new com.qifun.jsonStream.crossPlatformTypes.ArrayList(tarrayView.tarray());

      var mapBuilder:scala.collection.mutable.Builder<scala.Tuple2<Int, Int>, scala.concurrent.stm.TMap<Int, Int>> = scala.concurrent.stm.TMap.TMapSingleton.MODULE.newBuilder();
      mapBuilder.plusEquals(new scala.Tuple2(42, 1764));
      mapBuilder.plusEquals(new scala.Tuple2(14, 169));
      mapBuilder.plusEquals(new scala.Tuple2(25, 625));
      mapBuilder.plusEquals(new scala.Tuple2(256, 65536));
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(mapBuilder.result());
    #elseif cs
      var set = new dotnet.system.collections.generic.HashSet;
      set.Add(30);
      set.Add(82);
      set.Add(255);
      set.Add(4099);
      set.Add(96354);
      o.set = new com.qifun.jsonStream.crossPlatformTypes.Set(set);
      
      var list = new dotnet.system.collections.generic.List;
      list.Add(1);
      list.Add(1);
      list.Add(2);
      list.Add(3);
      list.Add(5);
      o.list = new com.qifun.jsonStream.crossPlatformTypes.ArrayList(list);
      
      var map = new dotnet.system.collections.generic.Dictionary;
      map.Add(42, 1764);
      map.Add(14, 169);
      map.Add(25, 625);
      map.Add(256, 65536);
      o.map = new com.qifun.jsonStream.crossPlatformTypes.ArrayList(map);
      
     #elseif (java && scala && !scala_stm)
      var setBuilder:scala.collection.mutable.Builder<Int, Dynamic> = scala.collection.immutable.Set.SetSingleton.MODULE.newBuilder();
      setBuilder.plusEquals(30);
      setBuilder.plusEquals(82);
      setBuilder.plusEquals(255);
      setBuilder.plusEquals(4099);
      setBuilder.plusEquals(96354);
      o.set = new com.qifun.jsonStream.crossPlatformTypes.Set(setBuilder.result());
      
      var seqBuilder:scala.collection.mutable.Builder<Int, Dynamic> = scala.collection.immutable.Seq.SeqSingleton.MODULE.newBuilder();
      seqBuilder.plusEquals(1);
      seqBuilder.plusEquals(1);
      seqBuilder.plusEquals(2);
      seqBuilder.plusEquals(3);
      seqBuilder.plusEquals(5);
      o.list = new com.qifun.jsonStream.crossPlatformTypes.ArrayList(seqBuilder.result());

      var mapBuilder:scala.collection.mutable.Builder<scala.Tuple2<Int, Int>, Dynamic> = scala.collection.immutable.Map.MapSingleton.MODULE.newBuilder();
      mapBuilder.plusEquals(new scala.Tuple2(42, 1764));
      mapBuilder.plusEquals(new scala.Tuple2(14, 169));
      mapBuilder.plusEquals(new scala.Tuple2(25, 625));
      mapBuilder.plusEquals(new scala.Tuple2(256, 65536));
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(mapBuilder.result());
    #end  
    
    var jsonStream = JsonSerializer.serializeRaw(new RawJson({list:[ { Int:1 }, { Int:1 }, { Int:2 }, { Int:3 }, { Int:5 } ],
     map:[[ { Int:14 }, { Int:169 } ], [ { Int:25 }, { Int:625 } ], [ { Int:42 }, { Int:1764 } ], 
     [ { Int:256 }, { Int:65536 } ]], set : [ { Int : 30 }, { Int : 82 }, { Int : 255 }, { Int : 4099 }, { Int : 96354 } ] }));
    var o2:AbstructTypeTest = JsonDeserializer.deserialize(jsonStream);
    assertDeepEquals(o, o2);
  }
}