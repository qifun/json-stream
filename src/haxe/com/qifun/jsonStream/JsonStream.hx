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

package com.qifun.jsonStream;
import haxe.Int64;
import haxe.io.Bytes;

@:final class JsonStreamPair
{
  public var key(default, null):String;
  public var value(default, null):JsonStream;
  public function new(key:String, value:JsonStream)
  {
    this.key = key;
    this.value = value;
  }
}

/**
  结构化的JSON数据流。
  
  既可能用于序列化，也可能用于反序列化。
**/
enum JsonStream
{
  //safe type
  NUMBER(value:Float);
  STRING(value:String);
  TRUE;
  FALSE;
  NULL;
  OBJECT(pairs:Iterator<JsonStreamPair>);
  ARRAY(elements:Iterator<JsonStream>);
  //unsafe type
  INT32(value:Int);
  INT64(high:Int, low:Int);
  BINARY(value:Bytes);
}

