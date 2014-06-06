package ;
#if macro
import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.macro.Expr;
#end
import com.qifun.jsonStream.JsonDeserializer;
import haxe.macro.MacroStringTools;
import haxe.unit.TestCase;
import haxe.PosInfos;

@:autoBuild(JsonTestCase.build())
class JsonTestCase extends TestCase
{
  @:noUsing
  macro public static function build():Array<Field>
  {
    var localClass = Context.getLocalClass().get();
    var fields = Context.getBuildFields();
    if (TypeTools.findField(localClass, "main", true) == null)
    {
      var localClassName = localClass.name;
      var localModule = localClass.module;
      var moduleLast = switch (localModule.lastIndexOf("."))
      {
        case -1: localModule;
        case dotIndex: localModule.substring(dotIndex + 1);
      }
      var localTypaPath =
        {
          pack: localClass.pack,
          sub: localClass.name,
          name: moduleLast,
        };
      fields.push(
        {
          name: "main",
          pos: Context.currentPos(),
          access: [ AStatic ],
          kind: FFun(
            {
              args: [],
              ret: null,
              expr: macro
              {
                haxe.Timer.delay(
                  function()
                  {
                    var runner = new haxe.unit.TestRunner();
                    runner.add(new $localTypaPath());
                    var isSuccess = runner.run();
                    if (!isSuccess)
                    {
                      throw runner.result;
                    }
                  }, 0);
              }
            })
        });
    }
    return fields;
  }

  macro static function testData<T>(data:ExprOf<T>):ExprOf<Void> return
  {
    var dataComplexType = TypeTools.toComplexType(Context.typeof(data));
    macro
    {
      {
        var builder:com.qifun.jsonStream.JsonBuilder<$dataComplexType> =
          com.qifun.jsonStream.JsonBuilderFactory.newBuilder();
        var stream = com.qifun.jsonStream.JsonSerializer.serialize($data);
        builder.setStream(stream);
        assertDeepEquals(
          com.qifun.jsonStream.JsonDeserializer.deserializeRaw(
            com.qifun.jsonStream.JsonSerializer.serialize($data)),
          com.qifun.jsonStream.JsonDeserializer.deserializeRaw(
            com.qifun.jsonStream.JsonSerializer.serialize(builder.result)));
      }
      {
        var stream = com.qifun.jsonStream.JsonSerializer.serialize($data);
        var data2:$dataComplexType = com.qifun.jsonStream.JsonDeserializer.deserialize(stream);
        assertDeepEquals(
          com.qifun.jsonStream.JsonDeserializer.deserializeRaw(
            com.qifun.jsonStream.JsonSerializer.serialize($data)),
          com.qifun.jsonStream.JsonDeserializer.deserializeRaw(
            com.qifun.jsonStream.JsonSerializer.serialize(data2)));
      }
    }


  }

  function assertDeepEquals(expected: Dynamic, actual: Dynamic, ?c : PosInfos):Void
 	{
		currentTest.done = true;
		if (!JsonEquality.deepEquals(actual, expected)){
			currentTest.success = false;
			currentTest.error   = "expected '" + expected + "' but was '" + actual + "'";
			currentTest.posInfos = c;
			throw currentTest;
		}
	}

}
