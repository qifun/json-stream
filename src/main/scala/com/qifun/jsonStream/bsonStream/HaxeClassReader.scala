package com.qifun.jsonStream.bsonStream

import reactivemongo.api.collections.buffer.RawBSONDocumentDeserializer
import com.qifun.jsonStream.JsonStream
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import reactivemongo.bson.buffer.ReadableBuffer
import com.qifun.jsonStream.io.BsonParser

class HaxeClassReader[T](haxeDeserializeFunction: JsonStream => T) extends RawBSONDocumentDeserializer[T] {
  def deserialize(buffer: ReadableBuffer):T = {
    val jsonStream = BsonParser.readBsonStream(buffer)
    haxeDeserializeFunction(jsonStream)
  }
}