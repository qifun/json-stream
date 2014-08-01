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
