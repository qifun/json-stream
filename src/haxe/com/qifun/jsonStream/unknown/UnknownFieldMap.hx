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

import haxe.ds.StringMap;

/**
  定义数据结构时，可以使用本`UnknownFieldMap`捕获反序列化中无法识别的字段。
  
  如果数据结构是类，类定义中存在`var unknownFieldMap:UnknownFieldMap;`成员，那么反序列化这个类时，无法识别的字段会保存在你定义的`unknownFieldMap`中。例如：
  <pre>`class MyEntity
{
  var knownField1:Int;
  var knownField2:Bool;
  var unknownFieldMap:UnknownFieldMap;
}`</pre>
  
  如果数据结构是枚举，枚举构造函数定义中存在`unknownFieldMap:UnknownFieldMap`参数，那么反序列化这个构造函数时，无法识别的参数会保存在你定义的`unknownFieldMap`中。例如：
  <pre>`enum MyEnum
{
  CONSTRUCT_THAT_DOES_NOT_SUPPORT_UNKNOWN_FIELD_MAP(parameter1:Int, parameter2:Bool);
  CONSTRUCT_THAT_SUPPORTS_UNKNOWN_FIELD_MAP(parameter1:Int, parameter2:Bool, unknownFieldMap:UnknownFieldMap);
}`</pre>
  
 */
abstract UnknownFieldMap(StringMap<RawJson>)
{
  public inline function new(underlying:StringMap<RawJson>)
  {
    this = underlying;
  }
  
  public var underlying(get, never):StringMap<RawJson>;
  
  @:extern
  private inline function get_underlying():StringMap<RawJson> return this;
  
}
