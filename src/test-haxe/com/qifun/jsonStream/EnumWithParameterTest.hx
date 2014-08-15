package com.qifun.jsonStream;
using com.qifun.jsonStream.Plugins;
using com.qifun.jsonStream.SimpleBuildMacro;
import com.qifun.jsonStream.SimpleEntities;
import com.qifun.jsonStream.testUtil.JsonTestCase;

class EnumWithParameterTest extends JsonTestCase
{

  function testEnumValue2()
  {
    JsonTestCase.testData(SimpleEnum.ENUM_VALUE_2(1));
  }

}
