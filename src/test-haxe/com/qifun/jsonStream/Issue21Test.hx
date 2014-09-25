package com.qifun.jsonStream;
import com.qifun.jsonStream.crossPlatformTypes.CrossVector;
import com.qifun.jsonStream.io.PrettyTextPrinter;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.testUtil.JsonTestCase;
import com.qifun.jsonStream.serializerPlugin.PrimitiveSerializerPlugins;
import haxe.ds.Vector;
using com.qifun.jsonStream.Plugins;

// https://github.com/qifun/json-stream/issues/21
class Issue21Test extends JsonTestCase
{


  /*
  // Disabled due to https://github.com/HaxeFoundation/haxe/issues/3398
  public function testIntVector0():Void
  {
    var intVector0:CrossVector<Int> = CrossVector.make(0);
    assertEquals("[]", PrettyTextPrinter.toString(JsonSerializer.serialize(intVector0)));
  }
  */


  // Disabled due to https://github.com/HaxeFoundation/haxe/issues/3399
  public function testStringVector0():Void
  {
    var stringVector0:CrossVector<String> = CrossVector.make(0);
    var duplicated:CrossVector<String> = JsonDeserializer.deserialize(JsonSerializer.serialize(stringVector0));
    assertDeepEquals(stringVector0, duplicated);
  }

}
