package com.qifun.jsonStream;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.RawJson;
import haxe.ds.Option;
import haxe.Json;
import com.qifun.jsonStream.testUtil.JsonTestCase;
import haxe.unit.TestCase;


class RawTest extends JsonTestCase
{

  function testObject()
  {
    inline function selectLatter<T>(former:T, latter:T):T return latter;

    var nativeData =
    {
      field1: 123,
      field2: 8.0,
      field3: "foo",
      field4: ([ "foo", null, [], "bar", ([ ([ [], 2, null, { a: 0, } ]:Array<Dynamic>), "baz", [], ]: Array<Dynamic>), { b: null } ]: Array<Dynamic>),
      field5: null,
    }
    var data = new RawJson(nativeData);
    var stream = JsonSerializer.serializeRaw(data);
    var data2 = JsonDeserializer.deserializeRaw(stream);
    var nativeData2 = selectLatter(nativeData, data2.underlying);
    Some(nativeData2).match(Some(
    {
      field1: 123,
      field2: 8.0,
      field3: "foo",
      field4: [ "foo", null, [], "bar", (_:Array<Dynamic>) => [ (_:Array<Dynamic>) => [ [], 2, null, (_: { ?a:Int }) => { a: 0, } ], "baz", [], ], (_: { ?b:Dynamic }) => { b: null } ],
      field5: null,
    }));

    assertDeepEquals(data, data2);
  }

}
