package ;
import haxe.unit.TestCase;
import haxe.PosInfos;

class JsonTestCase extends TestCase
{

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
