/*
 * json-stream
 * Copyright 2014 深圳岂凡网络有限公司 (Shenzhen QiFun Network Corp., LTD)
 * 
 * Author: 杨博 (Yang Bo) <pop.atry@gmail.com>, 张修羽 (Zhang Xiuyu) <95850845@qq.com>
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
