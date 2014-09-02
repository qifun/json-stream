package com.qifun.jsonStream.bsonStream

import reactivemongo.api.collections.buffer.RawBSONDocumentDeserializer
import com.qifun.jsonStream.JsonStream
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import reactivemongo.bson.buffer.ReadableBuffer
import reactivemongo.bson.BSONDocument
import com.qifun.jsonStream.io.BsonReader
import reactivemongo.bson.buffer.DefaultBufferHandler

class BsonStreamDeserializer[T](
  haxeDeserializeFunction: JsonStream => T) extends RawBSONDocumentDeserializer[T] {
  def deserialize(buffer: ReadableBuffer): T = {
    val toJsonStreamBuffer = new ChannelBufferWritableBuffer
    val length = buffer.readInt()
    while (buffer.readable > 1) //the last byte of buffer is 0x0
    {
      val code = buffer.readByte()
      val name = buffer.readCString()
      if (code == 0x03 || name == "Content") {
        val contentLength = buffer.readInt()
        toJsonStreamBuffer.writeInt(contentLength)
        toJsonStreamBuffer.writeBytes(buffer.slice(contentLength - 4))
        toJsonStreamBuffer.writeByte(0)
      } else {
        DefaultBufferHandler.handlersByCode.get(code).map(_.read(buffer))
      }
    }

    val jsonStream = BsonReader.readBsonStream(toJsonStreamBuffer.toReadableBuffer)
    haxeDeserializeFunction(jsonStream)
  }
}