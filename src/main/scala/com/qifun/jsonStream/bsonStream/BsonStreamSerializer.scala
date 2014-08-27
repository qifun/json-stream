package com.qifun.jsonStream.bsonStream

import reactivemongo.api.collections.buffer.RawBSONDocumentSerializer
import com.qifun.jsonStream.JsonStream
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import reactivemongo.bson.BSONDocument
import com.qifun.jsonStream.io.BsonWriter
import scala.util.control.Exception

class BsonStreamSerializer[T](
  haxeSerializeFunction: T => JsonStream) extends RawBSONDocumentSerializer[T] {
  def serialize(obj: T) = {
    val writeableBuffer = new ChannelBufferWritableBuffer
    val jsonStream = haxeSerializeFunction(obj)
    writeableBuffer.writeInt(0);
    writeableBuffer.writeByte(0x03);
    writeableBuffer.writeCString("Content");
    BsonWriter.writeBsonObject(writeableBuffer, jsonStream.params.__get(0))
    writeableBuffer.setInt(0, writeableBuffer.index + 1)
    writeableBuffer.writeByte(0)
    writeableBuffer
  }
}
