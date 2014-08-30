/*
 * json-stream
 * Copyright 2014 深圳岂凡网络有限公司 (Shenzhen QiFun Network Corp., LTD)
 * 
 * Author: 杨博 (Yang Bo) <pop.atry@gmail.com>, 张修羽 (Zhang Xiuyu) <zxiuyu@126.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
