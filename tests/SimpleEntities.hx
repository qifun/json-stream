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

abstract SimpleAbstract(Int) from Int to Int
{
}
