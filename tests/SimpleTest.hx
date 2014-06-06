import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonBuilderFactory;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.RawJson;
import haxe.unit.TestCase;
import SimpleEntities;
using com.qifun.jsonStream.Plugins;
using SimpleBuildMacro;

class SimpleTest extends JsonTestCase
{
  function testEmptyBuilder()
  {
    var builder:JsonBuilder<SimpleClass> = JsonBuilderFactory.newBuilder();
    builder.setObject().end();
    assertEquals(null, builder.result.foo);
  }

  function testNullBuilder()
  {
    var builder:JsonBuilder<SimpleClass> = JsonBuilderFactory.newBuilder();
    builder.setNull();
    assertEquals(null, builder.result);
  }

  function testUnmatchedBuilder()
  {
    var builder:JsonBuilder<SimpleClass> = JsonBuilderFactory.newBuilder();
    try
    {
      builder.setNumber(1.1);
    }
    catch (builderError:JsonBuilderError)
    {
      assertTrue(builderError.match(UNMATCHED_JSON_TYPE(NUMBER(1.1), [ "OBJECT", "NULL" ])));
    }
  }

  function testAddString()
  {
    var builder:JsonBuilder<SimpleClass> = JsonBuilderFactory.newBuilder();
    {
      var objectBuilder = builder.setObject();
      objectBuilder.addString("foo", "bar");
      objectBuilder.end();
    }
    assertEquals("bar", builder.result.foo);
  }

  function testSetStream()
  {
    var builder:JsonBuilder<SimpleClass> = JsonBuilderFactory.newBuilder();
    builder.setStream(JsonSerializer.serializeRaw(new RawJson( { foo: "bar" } )));
    assertEquals(builder.result.foo, "bar");
  }

  function testSerializer()
  {
    var data = new SimpleClass();
    data.foo = "bar";
    assertDeepEquals({ foo: "bar" }, JsonDeserializer.deserializeRaw(JsonSerializer.serialize(data)));
  }

  function testSimple()
  {
    JsonTestCase.testData(SimpleEnum.ENUM_VALUE_1);
  }


}
