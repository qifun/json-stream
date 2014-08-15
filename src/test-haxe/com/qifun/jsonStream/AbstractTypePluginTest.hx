package com.qifun.jsonStream;

import com.dongxiguo.continuation.utils.Generator;
import com.dongxiguo.continuation.Continuation;
import com.qifun.jsonStream.io.PrettyTextPrinter;
import haxe.io.BytesOutput;
using com.qifun.jsonStream.Plugins;
using com.qifun.jsonStream.MacroTest;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;

class AbstractTypePluginTest extends JsonTestCase
{
  function testAbstractTypeSerializerPlugins()
  {
    var o = new AbstractTypeTest();
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
      o.list = new com.qifun.jsonStream.crossPlatformTypes.Vector(tarrayView.tarray());

      var mapBuilder:scala.collection.mutable.Builder<scala.Tuple2<Int, Int>, scala.concurrent.stm.TMap<Int, Int>> = scala.concurrent.stm.TMap.TMapSingleton.MODULE.newBuilder();
      mapBuilder.plusEquals(new scala.Tuple2(42, 1764));
      mapBuilder.plusEquals(new scala.Tuple2(14, 169));
      mapBuilder.plusEquals(new scala.Tuple2(25, 625));
      mapBuilder.plusEquals(new scala.Tuple2(256, 65536));
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(mapBuilder.result());
    #elseif cs
      var set = new dotnet.system.collections.generic.HashSet();
      set.Add(30);
      set.Add(82);
      set.Add(255);
      set.Add(4099);
      set.Add(96354);
      o.set = new com.qifun.jsonStream.crossPlatformTypes.Set(set);
      o.list = new com.qifun.jsonStream.crossPlatformTypes.Vector(haxe.ds.Vector.fromArrayCopy([1, 1, 2, 3, 5]));

      var map = new dotnet.system.collections.generic.Dictionary();
      map.Add(42, 1764);
      map.Add(14, 169);
      map.Add(25, 625);
      map.Add(256, 65536);
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(map);
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
      o.list = new com.qifun.jsonStream.crossPlatformTypes.Vector(seqBuilder.result());

      var mapBuilder:scala.collection.mutable.Builder<scala.Tuple2<Int, Int>, Dynamic> = scala.collection.immutable.Map.MapSingleton.MODULE.newBuilder();
      mapBuilder.plusEquals(new scala.Tuple2(42, 1764));
      mapBuilder.plusEquals(new scala.Tuple2(14, 169));
      mapBuilder.plusEquals(new scala.Tuple2(25, 625));
      mapBuilder.plusEquals(new scala.Tuple2(256, 65536));
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(mapBuilder.result());
    #end
    
    var jsonStream = JsonSerializer.serialize(o);
    trace(jsonStream);
    assertDeepEquals(
    new RawJson({list:[1, 1, 2, 3, 5],
     map:[[14, 169], [25, 625], [42, 1764],
     [256,65536]], set :[30,82,255,4099,96354] })
    , JsonDeserializer.deserializeRaw(jsonStream));
  }

  function testAbstractTypeDeseralizerPlugins()
  {
    var o = new AbstractTypeTest();
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
      o.list = new com.qifun.jsonStream.crossPlatformTypes.Vector(tarrayView.tarray());

      var mapBuilder:scala.collection.mutable.Builder<scala.Tuple2<Int, Int>, scala.concurrent.stm.TMap<Int, Int>> = scala.concurrent.stm.TMap.TMapSingleton.MODULE.newBuilder();
      mapBuilder.plusEquals(new scala.Tuple2(42, 1764));
      mapBuilder.plusEquals(new scala.Tuple2(14, 169));
      mapBuilder.plusEquals(new scala.Tuple2(25, 625));
      mapBuilder.plusEquals(new scala.Tuple2(256, 65536));
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(mapBuilder.result());
    #elseif cs
      var set = new dotnet.system.collections.generic.HashSet();
      set.Add(30);
      set.Add(82);
      set.Add(255);
      set.Add(4099);
      set.Add(96354);
      o.set = new com.qifun.jsonStream.crossPlatformTypes.Set(set);

      o.list = new com.qifun.jsonStream.crossPlatformTypes.Vector(haxe.ds.Vector.fromArrayCopy([1, 1, 2, 3, 5]));

      var map = new dotnet.system.collections.generic.Dictionary();
      map.Add(42, 1764);
      map.Add(14, 169);
      map.Add(25, 625);
      map.Add(256, 65536);
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(map);

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
      o.list = new com.qifun.jsonStream.crossPlatformTypes.Vector(seqBuilder.result());

      var mapBuilder:scala.collection.mutable.Builder<scala.Tuple2<Int, Int>, Dynamic> = scala.collection.immutable.Map.MapSingleton.MODULE.newBuilder();
      mapBuilder.plusEquals(new scala.Tuple2(42, 1764));
      mapBuilder.plusEquals(new scala.Tuple2(14, 169));
      mapBuilder.plusEquals(new scala.Tuple2(25, 625));
      mapBuilder.plusEquals(new scala.Tuple2(256, 65536));
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(mapBuilder.result());
    #end

    var jsonStream = JsonSerializer.serializeRaw(new RawJson({list:[1, 1, 2, 3, 5],
     map:[[14, 169], [25, 625], [42, 1764],
     [256,65536]], set :[30,82,255,4099,96354] })); 
    var o2:AbstractTypeTest = JsonDeserializer.deserialize(jsonStream);
    assertDeepEquals(o, o2);
  }
}
