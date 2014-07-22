package com.qifun.jsonStream.bsonStream

import scala.collection.mutable.Buffer
import java.nio.ByteBuffer
import haxe.io.Bytes
import reactivemongo.api.collections.buffer.RawBSONDocumentSerializer
import com.qifun.jsonStream.JsonStream
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import reactivemongo.bson.buffer.WritableBuffer
import com.qifun.jsonStream.io._
import reactivemongo.bson.BSONDocument

private[bsonStream] final class ByteBufferOutput(buffer: WritableBuffer) extends BsonOutput {
  override def writeByte(b: Int) = buffer.writeByte(b.toByte)
  override def writeInt32(b: Int) = buffer.writeInt(b)
  override def writeDouble(x: Double) = buffer.writeDouble(x)
  override def writeString(str: String) = buffer.writeString(str)
  override def writeCString(str: String) = buffer.writeCString(str)
  override def index() = buffer.index
  override def setInt(index: Int, value: Int) = buffer.setInt(index, value)
  //TODO other type
}