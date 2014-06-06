import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonBuilderFactory;
import haxe.unit.TestCase;
import SimpleEntities;
using com.qifun.jsonStream.Plugins;
using SimpleBuildMacro;

class SimpleTest extends TestCase
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


}
