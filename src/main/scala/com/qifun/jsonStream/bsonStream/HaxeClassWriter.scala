package com.qifun.jsonStream.bsonStream

import reactivemongo.api.collections.buffer.RawBSONDocumentSerializer
import com.qifun.jsonStream.JsonStream
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import com.qifun.jsonStream.io.BsonParser
import reactivemongo.bson.BSONDocument

class HaxeClassWriter[T](haxeSerializeFunction: T => JsonStream) extends RawBSONDocumentSerializer[T] {
  def serialize(obj: T) = {
    val writeableBuffer = new ChannelBufferWritableBuffer
    BsonParser.outputBsonStream(new ByteBufferOutput(writeableBuffer), haxeSerializeFunction(obj))
    writeableBuffer
  }
}
object UseBSONDocument {
  implicit object BSONDocumentWriteableBuffer extends RawBSONDocumentSerializer[BSONDocument] {
    def serialize(bsondoc: BSONDocument) = {
      val writeableBuffer = new ChannelBufferWritableBuffer
      BSONDocument.write(bsondoc, writeableBuffer)
      writeableBuffer
    }
  }
}

