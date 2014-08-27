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

package com.qifun.jsonStream.io;

#if java
import reactivemongo.bson.buffer.WritableBuffer;

@:forward(writeByte, writeInt, writeLong, writeDouble, writeString, writeCString, index, setInt)
abstract BsonOutput(WritableBuffer) { }

//#else cs


#else
interface IBsonOutput 
{
  public function index():Int;
  public function setInt(index:Int, value:Int):Void;
  public function writeCString(str:String):Void;
  public function writeString(str:String):Void;
  public function writeLong(l:haxe.Int64):Void;
  public function writeDouble(d:Float):Void;
  public function writeInt(i:Int):Void;
  public function writeByte(b:Int):Void;
}

@:forward(writeByte, writeInt, writeLong, writeDouble, writeString, writeCString, index, setInt)
abstract BsonOutput(IBsonOutput) { }
#end
