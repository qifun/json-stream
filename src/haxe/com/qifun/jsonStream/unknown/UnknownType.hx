package com.qifun.jsonStream.unknown;

/**
  定义数据结构时，可以使用本`UnknownEnumValue`捕获反序列化中无法识别的类型。

  那么反序列化`Dynamic`类型的类字段或者枚举参数时，如果发现数据类型无法识别，数据就会转换成`UnknownType`。

  如果某个非`@:final`的`class`中存在`var unknownType:UnknownType;`成员，
  符合`HasUnknownTypeSetter`或`HasUnknownTypeField`定义，
  那么反序列化该类型的类字段或者枚举参数时，如果发现数据类型无法识别，数据就会转换成`UnknownType`，然后存在你定义的`unknownType`中。
  这个类的其他所有字段都会保持默认值。例如：
  <pre>`class MyClass
{
  var field1:Int;
  var field2:Bool;
  var unknownType:UnknownType
}`</pre>
**/
class UnknownType
{

  public var type(default, null):String;
  public var data(default, null):RawJson;

  public function new(type:String, data:RawJson)
  {
    this.type = type;
    this.data = data;
  }

}

typedef HasUnknownTypeSetter =
{
  function new():Void;
  var unknownType(never, set):UnknownType;
}

typedef HasUnknownTypeField =
{
  function new():Void;
  var unknownType(null, default):UnknownType;
}
