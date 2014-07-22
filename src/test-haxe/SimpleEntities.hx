package ;
import haxe.ds.Vector;

@:final
class SimpleClass
{
  public function new() { }

  public var foo:String;
}

enum SimpleEnum
{
  ENUM_VALUE_1;
  ENUM_VALUE_2(parameter:Int);
}

//abstract SimpleAbstract(Int) // Error due to https://github.com/HaxeFoundation/haxe/issues/3110
abstract SimpleAbstract(String)
{
  public function new(underlying:String)
  {
    this = underlying;
  }
}

@:final
class UserInfo 
{
	public function new() {}
  public var hp:Int;
  public var mp:Int;
  public var skills:Array<Int> = [];
}

@:final
class User
{
  public function new() {}
	public var info:UserInfo = new UserInfo();
}



@:final
class TypeTest
{
  public function new() {}
  public var i:Int;
  public var str:String;
  public var f:Float;
  public var bo:Bool;
 // public var nu:Void;
}