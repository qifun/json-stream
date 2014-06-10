using com.qifun.jsonStream.Plugins;
using SimpleBuildMacro;
import SimpleEntities;

class EnumWithParameterTest extends JsonTestCase
{

  function testEnumValue2()
  {
    JsonTestCase.testData(SimpleEnum.ENUM_VALUE_2(1));
  }

}
