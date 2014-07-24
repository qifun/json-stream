package com.qifun.jsonStream.bsonStream

import reactivemongo.api.collections.buffer.RawBSONDocumentSerializer
import reactivemongo.bson.BSONDocument
import reactivemongo.core.netty.ChannelBufferWritableBuffer
/**
 * 在使用ChannelCollection且需要用BSONDocument来作为参数进行数据库操作时，请import这个对象。
 */
object UseBSONDocument {
  implicit object BSONDocumentWriteableBuffer extends RawBSONDocumentSerializer[BSONDocument] {
    def serialize(bsonDocument: BSONDocument) = {
      val writeableBuffer = new ChannelBufferWritableBuffer
      BSONDocument.write(bsonDocument, writeableBuffer)
      writeableBuffer
    }
  }
}

