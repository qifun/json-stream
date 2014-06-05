package com.qifun.jsonStream.unknown;

/**
  定义数据结构时，可以使用本`UnknownEnumValue`捕获反序列化中无法识别的枚举值。

  如果枚举定义中存在`UNKNOWN_ENUM_VALUE(unknownEnumValue:UnknownEnumValue)`构造函数，
  那么反序列化这个枚举时，无法识别的枚举值会转换成你定义的`UNKNOWN_ENUM_VALUE`。
  例如：
  <pre>`enum MyEnum
{
  KNOWN_ENUM_VALUE1(parameter1:Int, parameter2:Bool);
  KNOWN_ENUM_VALUE2;
  UNKNOWN_ENUM_VALUE(unknownEnumValue:UnknownEnumValue);
}`</pre>
**/
enum UnknownEnumValue
{
  UNKNOWN_CONSTANT_CONSTRUCTOR(constructorName:String);
  UNKNOWN_PARAMETERIZED_CONSTRUCTOR(constructorName:String, parameters:RawJson);
}
