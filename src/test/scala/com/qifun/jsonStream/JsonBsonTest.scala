package com.qifun.jsonStream

import reactivemongo.api._
import reactivemongo.bson._
import scala.concurrent.ExecutionContext
import scala.concurrent.ExecutionContext.Implicits.global
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
  def `array and sub object in Haxe objecte test`() : Unit = {
    val us = new UserTest()
    us.info.hp = Long.MaxValue 
    us.info.mp = 200
    us.info.skills.push(Integer.valueOf(9527))
    us.info.skills.push(Integer.valueOf(8888))

    val writeableBuffer = UserClass2Writer.serialize(us)
    val bson = BSONDocument.read(writeableBuffer.toReadableBuffer);
    for (i <- bson.stream.toList) {
      assertEquals(i.get._1, "info")
      assertEquals(i.get._2.code, 0x03)
      println(i.get._1 + "->" + i.get._2)
      val subBson = i.get._2.seeAsTry[BSONDocument].get
      for (j <- subBson.stream toList) {
        println("subBson :" + j.get._1 + "->" + j.get._2 + "code:" + j.get._2.code)
        if(j.get._1 == "skills"){
          for (k<- j.get._2.seeAsTry[BSONArray].get.stream.toList.map(_.get.seeAsTry[BSONInteger].get.value)) 
            println("elem of Array skill:" + k)
        }
      }
    }
    println(PrettyTextPrinter.toString(UserTestSerializer.serialize_com_qifun_jsonStream_UserTest(us)))
    writeableBuffer.buffer.clear()
    
    BSONDocument.write(bson, writeableBuffer)
    val obj = UserClass2Reader.deserialize(writeableBuffer.toReadableBuffer)    
    BSONDocument("info" -> BSONDocument("hp" -> 150.0, "mp" -> 200.0, "skills" -> Array(9527, 8888)))
    BSONDocument.write(bson, writeableBuffer)
    val obj2 = UserClass2Reader.deserialize(writeableBuffer.toReadableBuffer)
    println(obj.info.hp,obj2.info.hp)
    assertEquals(obj.info.hp, Long.MaxValue)
    assertEquals(obj.info.mp, 200)
    assertEquals(obj.info.skills.length, 2)
    assertEquals(obj.info.skills.__get(0), 9527.0)
    assertEquals(obj.info.skills.__get(1), 8888.0)
    assertEquals(obj2.info.hp, Long.MaxValue)
    assertEquals(obj2.info.mp, 200)
    assertEquals(obj2.info.skills.length, 2)
    assertEquals(obj2.info.skills.__get(0), 9527.0)
    assertEquals(obj2.info.skills.__get(1), 8888.0)
  }
  
  @Test
  def `primitiveTypeTest`() : Unit =
  {
    implicit object TypeTestWriter extends HaxeClassWriter[TypeTest](TypeTestSerializer.serialize_com_qifun_jsonStream_TypeTest)
    implicit object TypeTestReader extends HaxeClassReader[TypeTest](TypeTestDeserializer.deserialize_com_qifun_jsonStream_TypeTest) 
    val typeTest = new TypeTest
    typeTest.bo = true
    typeTest.f = 3.1415926
    typeTest.i = 42
    typeTest.str = "这是一个中文字符串。"
    val bson = BSONDocument.read(TypeTestWriter.serialize(typeTest).toReadableBuffer)
    for(i <- bson.stream.toList) {
      println(i.get._1 + "->" + i.get._2)
    }
    
    val writeableBuffer = new ChannelBufferWritableBuffer
    BSONDocument.write(bson,writeableBuffer)
    val obj = TypeTestReader.deserialize(writeableBuffer.toReadableBuffer)
    
    assertEquals(typeTest.bo, obj.bo)
    assertTrue(typeTest.f == obj.f)//assertEquals cann't compare double type
    assertEquals(typeTest.i, obj.i)
    assertEquals(typeTest.str, obj.str)
  } 
}
