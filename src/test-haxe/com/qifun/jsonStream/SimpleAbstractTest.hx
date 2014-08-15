package com.qifun.jsonStream;
using com.qifun.jsonStream.Plugins;
using com.qifun.jsonStream.SimpleIo;
import com.qifun.jsonStream.SimpleEntities;
import com.qifun.jsonStream.testUtil.JsonTestCase;
import com.qifun.jsonStream.JsonDeserializer;

class SimpleAbstractTest extends JsonTestCase
{

  function testSimpleAbstract()
  {
    JsonTestCase.testData(new SimpleAbstract("foo"));
  }

}
