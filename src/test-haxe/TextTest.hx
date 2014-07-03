package ;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.io.PrettyTextPrinter;
import com.qifun.jsonStream.io.TextParser;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.RawJson;
import haxe.io.BytesOutput;
import haxe.Json;
import haxe.io.StringInput;

class TextTest extends JsonTestCase
{

  public function testParser()
  {
    var nativeData =
    {
      field1: 123,
      field2: 8.0,
      field3: "foo",
      field4: ([ "foo", null, [], "bar", ([ ([ [], 2, null, { a: 0, } ]:Array<Dynamic>), "baz", [], ]: Array<Dynamic>), { b: null } ]: Array<Dynamic>),
      field5: null,
    }
    var text = Json.stringify(nativeData);
    var nativeData2 = JsonDeserializer.deserializeRaw(TextParser.parseString(text));
    assertDeepEquals(nativeData, nativeData2);
  }

  public function testPrinter()
  {
    var nativeData =
    {
      field1: 123,
      field2: 8.0,
      field3: "foo",
      field4: ([ "foo", null, [], "bar", ([ ([ [], 2, null, { a: 0, } ]:Array<Dynamic>), "baz", [], ]: Array<Dynamic>), { b: null } ]: Array<Dynamic>),
      field5: null,
    }
    var output = new BytesOutput();
    PrettyTextPrinter.print(output, JsonSerializer.serializeRaw(new RawJson(nativeData)));
    var text = output.getBytes().toString();
    //trace(text);
    var nativeData2 = Json.parse(text);
    assertDeepEquals(nativeData, nativeData2);
  }

}
