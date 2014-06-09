package ;
using com.qifun.jsonStream.Plugins;
using GenericClassBuildMacro;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonSerializer;
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
        data.array = [ [ [], null, [ null ]], null ];
        // Workaround for https://github.com/HaxeFoundation/haxe/issues/3118
        #if cs (data:Dynamic) #else data #end .a2 =
        [
          [ null, ],
          [
            {
              var data = new FinalClass2<Int, BaseClass<Int, Dynamic>>();
              data.a1 =
              {
                var data = new FinalClass2<Int, Dynamic>();
                data.a1 = "";
                data;
              }
              data;
            },
            null,
            new BaseClass<Int, BaseClass <Int, Dynamic>>(),
          ]
        ];
        data.self2 =
        {
          var data = new FinalClass2<Array<Array<BaseClass<Int, BaseClass<Int, Dynamic>>>> , Array<String>>();
          data.self = new BaseClass<Array<String>, BaseClass<Array<Array<BaseClass<Int, BaseClass<Int, Dynamic>>>>, Int>>();
          // Workaround for https://github.com/HaxeFoundation/haxe/issues/3118
          #if cs (data:Dynamic) #else data #end.a1 = [ null, null, null ];
          data.array =
          [
            [ "foo" ],
            [ "bar", "baz", "", null]
          ];
          data;
        }
        data;
      },
    ];
    JsonTestCase.testData(data);
  }


}
