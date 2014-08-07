import haxe.unit.TestRunner;
import com.qifun.jsonStream.JsonSerializer;
import com.qifun.jsonStream.JsonDeserializer;
import CSharpTest;
import CrossPlatformTypeTest;

using CSharpTestMacro;
using com.qifun.jsonStream.Plugins;

class Main
{

  static function testAll()
  {
    var runner = new TestRunner();
    runner.add(new RawTest());
    runner.add(new SimpleTest());
    runner.add(new SimpleAbstractTest());
    runner.add(new EnumWithParameterTest());
    runner.add(new Rpc2Test());
    runner.add(new GenericClassTest());
    runner.add(new TextTest());
    var isSuccess = runner.run();
    if (!isSuccess)
    {
      throw runner.result;
    }
  }

  public static function main()
  {
    CrossPlatformTypeTest.test();
    // 使用Timer以绕开在main中遇到异常时FlashDevelop调试器无法退出的Bug
    #if flash9
      haxe.Timer.delay(testAll, 0);
    #elseif cs
      testCSPlugins();
    #else
      testAll();
    #end
  }

  #if cs
  private static function testCSPlugins()
  {
    var csTest = new CSharpTest();
    csTest.list.Add(1);
    csTest.list.Add(2);
    csTest.list.Add(3);
    csTest.hashSet.Add(1);
    csTest.hashSet.Add(2);
    csTest.hashSet.Add(3);
    csTest.dictionary.Add(1, 2);
    csTest.dictionary.Add(2, 3);
    csTest.dictionary.Add(3, 1);
    var csTest2:CSharpTest = JsonDeserializer.deserialize(JsonSerializer.serialize(csTest));
    var enumerator:dotnet.system.collections.generic.IEnumerator<Int> = cast csTest2.list.GetEnumerator();
    while(enumerator.MoveNext())
    {
      trace(enumerator.Current);
    }
    var enumerator:dotnet.system.collections.generic.IEnumerator<Int> = cast csTest2.hashSet.GetEnumerator();
    while(enumerator.MoveNext())
    {
      trace(enumerator.Current);
    }
    var enumerator:dotnet.system.collections.generic.IEnumerator<dotnet.system.collections.generic.KeyValuePair<Int, Int>> = cast csTest2.dictionary.GetEnumerator();
    while(enumerator.MoveNext())
    {
      trace(enumerator.Current.Key + "->" + enumerator.Current.Value);
    }
  }
  #end
}
