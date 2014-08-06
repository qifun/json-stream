package com.qifun.jsonStream.bsonStream

import reactivemongo.api.collections.buffer.RawBSONDocumentSerializer
import com.qifun.jsonStream.JsonStream
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import reactivemongo.bson.BSONDocument
import com.qifun.jsonStream.io.BsonWriter
import scala.util.control.Exception

class HaxeClassWriter[T <: haxe.lang.HxObject](
  haxeSerializeFunction: T => JsonStream) extends RawBSONDocumentSerializer[T] {
  def serialize(obj: T) = {
    val writeableBuffer = new ChannelBufferWritableBuffer
    val jsonStream = haxeSerializeFunction(obj)
    writeableBuffer.writeInt(0);
    writeableBuffer.writeByte(0x03);
    writeableBuffer.writeCString("Content");
    BsonWriter.writeBsonObject(writeableBuffer, jsonStream.params.__get(0))
//    haxe.root.Type.enumIndex(jsonStream) match {
//      case 5 => BsonWriter.writeBsonObject(
//        writeableBuffer, jsonStream.params.__get(0)) //type of index '5' is Jsonstream(OBJECT)
//      case enumIndex: Int => throw (new IllegalArgumentException() {
//        val jsonStreamElemIndex = enumIndex
//        val except = 5
//      })
//    }
    writeableBuffer.setInt(0, writeableBuffer.index + 1)
    writeableBuffer.writeByte(0)
    writeableBuffer
  }
}
