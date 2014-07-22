package com.qifun.jsonStream.io;

import com.dongxiguo.continuation.utils.Generator;
import haxe.Constraints.Function;
import haxe.io.BytesBuffer;
import haxe.io.Input;
import haxe.io.Output;
import haxe.io.Eof;
import haxe.Json;
import com.dongxiguo.continuation.utils.Generator;
import com.dongxiguo.continuation.Continuation;
import com.qifun.jsonStream.JsonStream;

/*
Bson流格式
整个Bson流的长度，单位字节，类型Int32，4字节
----下面一段会重复出现
>下一个键值对的Value类型
>下一个键值对的Key，类型Cstring
>下一个键值对的Value
----
结束标记，0，类型Byte，1字节
 * */
class BsonParser
{
  public function new() { }
  
  private static function readBsonValue(buffer:BsonInput, valueTypeCode:Int):JsonStream return
  {
    switch(valueTypeCode)
    {
      case 0x01: // Double
      {
        JsonStream.NUMBER(buffer.readDouble());
      }
      case 0x02: // String
      {
        var str:String = buffer.readNString();
        JsonStream.STRING(str);
        }
      case 0x03: // BSONDocument
      {
        readBsonStream(buffer);
      }
      
      case 0x04: // array
      {
        var arrayBufferLength = buffer.readInt32();
        var arrayBuffer = buffer.slice(arrayBufferLength - 4);
        buffer.discard(arrayBufferLength - 4);
        JsonStream.ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
        {
          var lastLabel:Int = -1;
          while (arrayBuffer.readable() > 1)
          {     
            var code:Int = arrayBuffer.readByte();
            var label:Int = Std.parseInt(arrayBuffer.readCString());
            while (++lastLabel < label)
              yield(JsonStream.NULL).async();
            yield(readBsonValue(arrayBuffer, code)).async();
          }
        })));
      }
      /*
      case 0x05: // BSONBinary // Binary data ReactiveMongo代码中有TODO注释
        ;//TODO
      case 0x06: // BSONUndefined // undefined, 已经被BSON标准弃用
        ;//TODO              */
      case 0x07: // BSONObjectID // objectid,
      {
        var i:Int = -1;
        while (++i < 12)
          buffer.readByte();
        JsonStream.NULL;
      }
      case 0x08: // Boolean // boolean
      {
        buffer.readByte() == 1 ? JsonStream.TRUE:JsonStream.FALSE;
      }
      /*
      case 0x09: // DateTime // datetime, UTC datetime in a 64-Int
        ;//TODO
      case 0x0A: // Null // null
        ;//TODO
      case 0x0B: // regex
        ;//TODO
      case 0x0C: // BSONDBPointer // dbpointer 已经被BSON标准弃用
        ;//TODO
      case 0x0D: // BSONJavaScript // JS
        ;//TODO
      case 0x0E: // BSONSymbol // symbol
        ;//TODO
      case 0x0F: // BSONJavaScriptWS // JS with scope
        ;//TODO
        */
      case 0x10: // Int
      {
        JsonStream.NUMBER(buffer.readInt32());
      }
      /*
      case 0x11: // BSONTimestamp // timestamp,
        ;//TODO
      case 0x12: // Long // long, 64-Int
        ;//TODO
      case 0xFF: // min key Special type which compares lower than all other possible BSON element values.
        ;//TODO
      case 0x7F: // max key Special type which compares higher than all other possible BSON element values.
        ;//TODO
        */
      default: JsonStream.NULL;
    }
  }
  
  public static function readBsonStream(input:BsonInput):JsonStream return 
  {
    JsonStream.OBJECT(try
    {
      var length = input.readInt32();
      //此时bsonBufferEnd已经被读入，而bson长度中包括了bsonBufferEnd的4个字节.
      //如此相加之后这4个字节被额外重复计算了一次，所以实际结束位置需要减去4字节。
      var buffer = input.slice(length - 4);
      input.discard(length - 4);
      new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStreamPair>):Void
      {
        while (buffer.readable() > 1)
        {
          var valueTypeCode:Int = buffer.readByte();
          var key:String = buffer.readCString();
          yield(new JsonStreamPair(key, readBsonValue(buffer, valueTypeCode))).async();
        }
      }));
    }
    catch (e : Eof) 
    {
      //TODO 
      throw(Eof);
    });
  }
  
  //只有一个完整的BSON文档才能解析为Bson流
  public static function outputBsonStream(output:BsonOutput, value:JsonStream):Void
  {
    var now:Int = output.index();
    output.writeInt32(0);
    switch (value)
    {
      case OBJECT(iterator):
      {
        for (pair in iterator)
          outputPair(output, pair.key, pair.value);
      }
      default:
      {
        return;
      }
    }
    output.setInt(now, (output.index() - now + 1));
    output.writeByte(0x00);
  }
  
  private static function outputPair(output:BsonOutput, key:String, value:JsonStream):Void return
  {
    switch (value)
    {
      case STRING(value):
      {
        output.writeByte(0x02);
        output.writeCString(key);
        var str:String = Json.stringify(value);//这个字符串内容里面包括了一对引号，需要去掉
        output.writeString(str.substr(1, str.length - 2));
      }
      case NUMBER(value):
      {
        output.writeByte(0x01);
        output.writeCString(key);
        var tmp:Float = Std.parseFloat(Json.stringify(value));
        output.writeDouble(tmp);
      }
      case OBJECT(iterator):
      { 
        output.writeByte(0x03);
        output.writeCString(key);
        var now:Int = output.index();
        output.writeInt32(0);
        for (pair in iterator)
          outputPair(output, pair.key, pair.value);
        output.setInt(now, (output.index() - now + 1));
        output.writeByte(0x00);
        
      }
      case ARRAY(iterator):
      {
        output.writeByte(0x04);
        output.writeCString(key);
        var now:Int = output.index();
        output.writeInt32(0);
        var i = -1;
        for (element in iterator)
        {
          ++i;
          if (element == JsonStream.NULL)
            continue;
          outputPair(output, Std.string(i), element);
        }
        output.setInt(now, (output.index() - now + 1));
        output.writeByte(0x00);
      }
      case TRUE:
      {
        output.writeByte(0x08);
        output.writeCString(key);
        output.writeByte(0x01);
      }
      case FALSE:
      {
        output.writeByte(0x08);
        output.writeCString(key);
        output.writeByte(0x00);
      }
      case NULL:
      {
        output.writeByte(0x0A);
        output.writeCString(key);
      }
    }
  }
}