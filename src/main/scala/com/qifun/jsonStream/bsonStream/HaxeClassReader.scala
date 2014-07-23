package com.qifun.jsonStream.bsonStream

import reactivemongo.api.collections.buffer.RawBSONDocumentDeserializer
import com.qifun.jsonStream.JsonStream
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import reactivemongo.bson.buffer.ReadableBuffer
import com.qifun.jsonStream.io.BsonReader

class HaxeClassReader[T](haxeDeserializeFunction: JsonStream => T) extends RawBSONDocumentDeserializer[T] {
  def deserialize(buffer: ReadableBuffer):T = {
<<<<<<< HEAD
    val jsonStream = BsonReader.readBsonStream(buffer)
=======
    val jsonStream = BsonParser.readBsonStream(buffer)
>>>>>>> 5187e63426592747dfef051c3b7cdf8757495c09
    haxeDeserializeFunction(jsonStream)
  }
}