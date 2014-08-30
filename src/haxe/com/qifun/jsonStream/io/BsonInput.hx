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

package com.qifun.jsonStream.io;


#if (java)

import reactivemongo.bson.buffer.ReadableBuffer;

@:forward(readInt, readLong, readDouble, readString, readCString, discard, size, index, readable)
abstract BsonInput(ReadableBuffer) 
{
  inline function new(underlying:ReadableBuffer)
  {
    this = underlying;
  }

  public inline function readByte():Int
  {
    var byte = new java.lang.Byte(this.readByte());
    return byte.intValue();
  }
  
  public inline function slice(n:Int):BsonInput return
  {
    return new BsonInput(this.slice(n));
  }
}

//#else cs


#else
interface IBsonInput
{
  public function readByte():Int;
  public function readInt():Int;
  public function readLong():haxe.Int64;
  public function readDouble():Float;
  public function discard(n:Int):Void;
  public function index():Int;
  public function size():Int;
  public function slice(n: Int):IBsonInput;
  public function readString():String;
  public function readCString():String;
  public function readable():Int;
}

@:forward(readByte, readInt, readLong, readDouble, readString, readCString, discard, slice, size, index, readable)
abstract BsonInput(IBsonInput)
{
  inline function new(underlying:IBsonInput)
  {
    this = underlying;
  }

  
  public inline function slice(n:Int):BsonInput return
  {
    return new BsonInput(this.slice(n));
  }
}

#end
