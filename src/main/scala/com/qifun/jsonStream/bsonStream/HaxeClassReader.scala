package com.qifun.jsonStream.bsonStream

import reactivemongo.api.collections.buffer.RawBSONDocumentDeserializer
import com.qifun.jsonStream.JsonStream
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import reactivemongo.bson.buffer.ReadableBuffer
import com.qifun.jsonStream.io.BsonReader

class HaxeClassReader[T <: haxe.lang.HxObject](
  haxeDeserializeFunction: JsonStream => T) extends RawBSONDocumentDeserializer[T] {
  def deserialize(buffer: ReadableBuffer): T = {
    val jsonStream = BsonReader.readBsonStream(buffer)
    haxeDeserializeFunction(jsonStream)
  }
}