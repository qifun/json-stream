package com.qifun.jsonStream.bsonStream

import reactivemongo.api.collections.buffer.RawBSONDocumentSerializer
import com.qifun.jsonStream.JsonStream
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import reactivemongo.bson.BSONDocument
import com.qifun.jsonStream.io.BsonWriter

class HaxeClassWriter[T](haxeSerializeFunction: T => JsonStream) extends RawBSONDocumentSerializer[T] {
  def serialize(obj: T) = {
    val writeableBuffer = new ChannelBufferWritableBuffer
    BsonWriter.writeBsonStream(writeableBuffer, haxeSerializeFunction(obj))
    writeableBuffer
  }
}
