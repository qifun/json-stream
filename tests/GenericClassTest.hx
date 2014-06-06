package ;
using com.qifun.jsonStream.Plugins;
using GenericClassBuildMacro;
import GenericClasses;

class GenericClassTest extends JsonTestCase
{
  function testEmpty()
  {
    JsonTestCase.testData(new FinalClass<Int>());
    JsonTestCase.testData(new FinalClass<Dynamic>());
    JsonTestCase.testData(new FinalClass<haxe.Int64>());
    JsonTestCase.testData(new FinalClass<StringBuf>());
    JsonTestCase.testData(new BaseClass<Int, StringBuf>());
    JsonTestCase.testData(new BaseClass2<FinalClass<Int>, Int, StringBuf>());
    JsonTestCase.testData(new BaseClass2<Dynamic, Int, StringBuf>());
  }

  function testComplex()
  {
    var data = new BaseClass2<FinalClass<Int>, Int, StringBuf > ();
    data.array =
    [
      {
        var data = new FinalClass<Int>();
        data.array = [[[]]];
        data;
      },
    ];
    JsonTestCase.testData(data);
  }


}
