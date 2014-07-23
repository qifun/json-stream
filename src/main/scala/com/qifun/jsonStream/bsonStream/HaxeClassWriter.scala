package com.qifun.jsonStream.bsonStream

import reactivemongo.api.collections.buffer.RawBSONDocumentSerializer
import com.qifun.jsonStream.JsonStream
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import com.qifun.jsonStream.io.BsonParser
import reactivemongo.bson.BSONDocument

class HaxeClassWriter[T](haxeSerializeFunction: T => JsonStream) extends RawBSONDocumentSerializer[T] {
  def serialize(obj: T) = {
    val writeableBuffer = new ChannelBufferWritableBuffer
    BsonParser.outputBsonStream(writeableBuffer, haxeSerializeFunction(obj))
    writeableBuffer
  }
}
