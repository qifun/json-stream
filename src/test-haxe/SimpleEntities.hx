package ;

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
