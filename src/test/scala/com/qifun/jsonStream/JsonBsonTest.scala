package com.qifun.jsonStream

import reactivemongo.api._
import reactivemongo.bson._
import scala.concurrent.ExecutionContext
import java.util.concurrent.Future
import reactivemongo.api.collections.GenericCollectionProducer
import reactivemongo.api.collections.buffer.ChannelCollection
import reactivemongo.bson.buffer.WritableBuffer
import reactivemongo.core.netty.ChannelBufferWritableBuffer
import reactivemongo.core.protocol.ChannelBufferWritable
import reactivemongo.api.collections.buffer.RawBSONDocumentSerializer
import com.qifun.jsonStream._
import com.qifun.jsonStream.bsonStream.UseBSONDocument._
import haxe.io.Output
import com.qifun.jsonStream.io.PrettyTextPrinter
import org.junit.Assert._
import org.junit.Test
import com.qifun.jsonStream.io._
import com.qifun.jsonStream.bsonStream._
class JsonBsonTest {

  implicit object UserClass2Writer extends HaxeClassWriter[UserTest](UserTestSerializer.serialize_com_qifun_jsonStream_UserTest)
  implicit object UserClass2Reader extends HaxeClassReader[UserTest](UserTestDeserializer.deserialize_com_qifun_jsonStream_UserTest)

  implicit object UserInfoClass2Writer extends HaxeClassWriter[UserInfoTest](UserTestSerializer.serialize_com_qifun_jsonStream_UserInfoTest)
  implicit object UserInfoClass2Reader extends HaxeClassReader[UserInfoTest](UserTestDeserializer.deserialize_com_qifun_jsonStream_UserInfoTest)

  @Test
  def `array and sub object in Haxe objecte test`(): Unit = {
    val us = new UserTest()
    us.info.hp = Long.MaxValue
    us.info.mp = 200
    us.info.skills.push(Integer.valueOf(9527))
    us.info.skills.push(Integer.valueOf(8888))
    val byteArray: Array[Byte] = Array[Byte](
      0x77.toByte, 0xD5.toByte, 0xD8.toByte, 0x6B.toByte, 0xB7.toByte, 0xD8.toByte, 0xE6.toByte, 0x89.toByte);
    for (i <- byteArray) println(i)
    us.info.md5Code = haxe.io.Bytes.alloc(byteArray.length);
    for (i <- 0 until byteArray.length) us.info.md5Code.set(i, byteArray(i))
    val writeableBuffer = UserClass2Writer.serialize(us)
    val bson = BSONDocument.read(writeableBuffer.toReadableBuffer);
    for (i <- bson.stream.toList) {
      assertEquals(i.get._1, "info")
      assertEquals(i.get._2.code, 0x03)
      println(i.get._1 + "->" + i.get._2)
      val subBson = i.get._2.seeAsTry[BSONDocument].get
      for (j <- subBson.stream toList) {
        println("subBson :" + j.get._1 + "->" + j.get._2 + "code:" + j.get._2.code)
        if (j.get._1 == "skills") {
          for (k <- j.get._2.seeAsTry[BSONArray].get.stream.toList.map(_.get.seeAsTry[BSONInteger].get.value))
            println("elem of Array skill:" + k)
        }
        if (j.get._1 == "md5Code") {
          println(j.get._2.seeAsTry[BSONBinary].get.value.readable)
        }
      }
    }
    val bson2 = BSONDocument("info" -> BSONDocument(
        "hp" -> Long.MaxValue, "mp" -> 200, "skills" -> Array(9527, 8888),
        "md5Code" ->BSONBinary(byteArray, Subtype(0x00))))
    println(PrettyTextPrinter.toString(UserTestSerializer.serialize_com_qifun_jsonStream_UserTest(us)))
    writeableBuffer.buffer.clear()
    BSONDocument.write(bson, writeableBuffer)
    val rbuffer = writeableBuffer.toReadableBuffer()
    val arr = rbuffer.readArray(rbuffer.readable)
    for(i <- arr ) print(i +" ")
    val obj = UserClass2Reader.deserialize(writeableBuffer.toReadableBuffer)
    println(obj.info.md5Code.length)
    for (i <- 0 until 8) println(obj.info.md5Code.get(i))
    assertEquals(obj.info.hp, Long.MaxValue)
    assertEquals(obj.info.mp, 200)
    assertEquals(obj.info.skills.length, 2)
    assertEquals(obj.info.skills.__get(0), 9527.0)
    assertEquals(obj.info.skills.__get(1), 8888.0)
    val arrayHasDeserialize: Array[Byte] = {for (i <- 0 until 8) yield obj.info.md5Code.get(i).toByte}.toArray
    assertArrayEquals(arrayHasDeserialize, byteArray)
  }

  @Test
  def `primitiveTypeTest`(): Unit =
    {
      implicit object TypeTestWriter extends HaxeClassWriter[TypeTest](TypeTestSerializer.serialize_com_qifun_jsonStream_TypeTest)
      implicit object TypeTestReader extends HaxeClassReader[TypeTest](TypeTestDeserializer.deserialize_com_qifun_jsonStream_TypeTest)
      val typeTest = new TypeTest
      typeTest.bo = true
      typeTest.f = 3.1415926
      typeTest.i = 42
      typeTest.str = "这是一个中文字符串。"
      typeTest.seq = scala.collection.Seq(Integer.valueOf(1),Integer.valueOf(2))
      val jsonStream = TypeTestSerializer.serialize_com_qifun_jsonStream_TypeTest(typeTest)

      val obj = TypeTestDeserializer.deserialize_com_qifun_jsonStream_TypeTest(jsonStream)

      assertEquals(typeTest.bo, obj.bo)
      assertTrue(typeTest.f == obj.f) //assertEquals cann't compare double type
      assertEquals(typeTest.i, obj.i)
      assertEquals(typeTest.str, obj.str)
      assertArrayEquals(typeTest.seq.toArray, obj.seq.toArray)
    }
}
