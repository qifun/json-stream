package com.qifun.jsonStream;
import haxe.unit.TestCase;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.testUtil.JsonTestCase;
using com.qifun.jsonStream.CSharpTestMacro;
import com.dongxiguo.continuation.utils.Generator;
import com.dongxiguo.continuation.Continuation;
using com.qifun.jsonStream.Plugins;

class CSharpPluginsTest extends JsonTestCase
{
 #if cs
 function testCSPlugins()
  {
    var csTest = new CSharpSimple();
    csTest.list.Add(1);
    csTest.list.Add(2);
    csTest.list.Add(3);
    csTest.hashSet.Add(1);
    csTest.hashSet.Add(2);
    csTest.hashSet.Add(3);
    csTest.dictionary.Add(1, 2);
    csTest.dictionary.Add(2, 3);
    csTest.dictionary.Add(3, 1);
    var jsonStream = JsonSerializer.serialize(csTest);
    var outputBuffer = new haxe.io.BytesOutput();
    var csTest2:CSharpSimple = JsonDeserializer.deserialize(jsonStream);
    
    var jsonStream2 = JsonStream.OBJECT(
      new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStreamPair>):Void
      {
        var jsonArray123 = JsonSerializer.serialize([1, 2, 3]);
        yield(new JsonStreamPair("list", jsonArray123)).async();
        yield(new JsonStreamPair("hashSet", jsonArray123)).async();
        yield(new JsonStreamPair("dictionary", JsonSerializer.serialize([[1, 2], [2, 3], [3, 1]]))).async();
      }
    )));
    
    var csTest3:CSharpSimple = JsonDeserializer.deserialize(jsonStream2);

    assertDeepEquals(csTest, csTest2);
    assertDeepEquals(csTest, csTest3);
    
  }
  #end
}