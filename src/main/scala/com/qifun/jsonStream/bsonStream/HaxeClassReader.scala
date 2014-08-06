package com.qifun.jsonStream.bsonStream

import reactivemongo.api.collections.buffer.RawBSONDocumentDeserializer
import com.qifun.jsonStream.JsonStream
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import reactivemongo.bson.buffer.ReadableBuffer
import reactivemongo.bson.BSONDocument
import com.qifun.jsonStream.io.BsonReader

class HaxeClassReader[T <: haxe.lang.HxObject](
  haxeDeserializeFunction: JsonStream => T) extends RawBSONDocumentDeserializer[T] {
  def deserialize(buffer: ReadableBuffer): T = {
    val bsonDocument = BSONDocument.read(buffer)
    val writeableBuffer = new ChannelBufferWritableBuffer
    BSONDocument.write(bsonDocument.getTry("Content").get.seeAsTry[BSONDocument].get, writeableBuffer)
    val jsonStream = BsonReader.readBsonStream(writeableBuffer.toReadableBuffer)
    haxeDeserializeFunction(jsonStream)
  }
}