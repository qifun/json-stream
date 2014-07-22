package com.qifun.jsonStream.bsonStream

import haxe.io.Input
import haxe.io.Eof
import haxe.lang.HaxeException
import reactivemongo.bson.buffer.ReadableBuffer
import com.qifun.jsonStream.io.BsonParser
import com.qifun.jsonStream.io.BsonInput

/*private[bsonStream]*/ final class ByteBufferInput(buffer: ReadableBuffer) extends BsonInput {

  override final def readByte() = {
    if (buffer.readable > 0)
      buffer.readByte()
    else throw HaxeException.wrap(new Eof)
  }

  override final def readInt32() = {
    if (buffer.readable > 0)
      buffer.readInt()
    else throw HaxeException.wrap(new Eof)
  }

  override final def readDouble() = {
    if (buffer.readable > 0)
      buffer.readDouble()
    else throw HaxeException.wrap(new Eof)
  }

  override final def readNString() = {
    if (buffer.readable > 0)
      buffer.readString()
    else throw HaxeException.wrap(new Eof)
  }

  override final def readCString() = {
    if (buffer.readable > 0)
      buffer.readCString()
    else throw HaxeException.wrap(new Eof)
  }

  override final def discard(n: Int) = buffer.discard(n);
  override final def slice(n: Int) = new ByteBufferInput(buffer.slice(n));
  override final def size() = buffer.size;
  override final def index() = buffer.index;
  override final def readable() = buffer.readable;

}