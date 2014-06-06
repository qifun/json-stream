using com.qifun.jsonStream.Plugins;
using SimpleBuildMacro;
import SimpleEntities;
import com.qifun.jsonStream.JsonDeserializer;

class SimpleAbstractTest extends JsonTestCase
{

  function testSimpleAbstract()
  {
    JsonTestCase.testData(new SimpleAbstract("foo"));
  }

}
