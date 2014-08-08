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
      o.set = new com.qifun.jsonStream.crossPlatformTypes.Set(scala.concurrent.stm.japi.STM.MODULE.newTSet().tset());
      o.list = new com.qifun.jsonStream.crossPlatformTypes.ArrayList(scala.concurrent.stm.japi.STM.MODULE.newTArray(0).tarray());
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(scala.concurrent.stm.japi.STM.MODULE.newTMap().tmap());
    #end  
    
    var jsonStream = JsonSerializer.serialize(o);
    assertDeepEquals({ set: [], list: [], map: [] }, JsonDeserializer.deserializeRaw(jsonStream));
  }
  
  function testAbstructTypeDeseralizerPlugins()
  {
    var o = new AbstructTypeTest();
    #if (java && scala_stm)
      o.set = new com.qifun.jsonStream.crossPlatformTypes.Set(scala.concurrent.stm.japi.STM.MODULE.newTSet().tset());
      o.list = new com.qifun.jsonStream.crossPlatformTypes.ArrayList(scala.concurrent.stm.japi.STM.MODULE.newTArray(0).tarray());
      o.map = new com.qifun.jsonStream.crossPlatformTypes.Map(scala.concurrent.stm.japi.STM.MODULE.newTMap().tmap());
    #end
    var jsonStream = JsonSerializer.serializeRaw(new RawJson({ set: [], list: [], map: [] }));
    var o2:AbstructTypeTest = JsonDeserializer.deserialize(jsonStream);
    assertDeepEquals(o, o2);
  }
}