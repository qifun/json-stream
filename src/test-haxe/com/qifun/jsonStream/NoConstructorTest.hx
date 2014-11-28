package com.qifun.jsonStream;

import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.io.TextParser;
import com.qifun.jsonStream.testUtil.JsonTestCase;

using com.qifun.jsonStream.deserializerPlugin.GeneratedDeserializerPlugin;
using com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins;
using com.qifun.jsonStream.deserializerPlugin.LowPriorityDynamicDeserializerPlugin;
using com.qifun.jsonStream.NoConstructorIo;

class NoConstructorTest extends JsonTestCase
{

  public function testNoConstructor()
  {
    var jsonString = "{ \"InvalidType\" : 1 }";
    try
    {
      var noConstructor:NoConstructor = JsonDeserializer.deserialize(TextParser.parseString(jsonString));
      throw "Expect JsonDeserializerError but nothing is thrown.";
    }
    catch (e:JsonDeserializerError)
    {
      this.assertMatch(NO_DESERIALIZER_FOR_TYPE("InvalidType"), e);
    }

  }

}