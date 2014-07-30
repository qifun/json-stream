package com.qifun.jsonStream.io;

import reactivemongo.bson.buffer.ReadableBuffer;

#if (java)
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
  public function readInt32():Int;
  public function readDouble():Float;
  public function discard(n:Int):Void;
  public function index():Int;
  public function size():Int;
  public function slice(n: Int):IBsonInput;
  public function readString():String;
  public function readCString():String;
  public function readable():Int;
}

@:forward(readByte, readInt, readDouble, readString, readCString, discard, slice, size, index, readable)
abstract BsonInput(IBsonInput) { }

#end