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
import java.types.Int8;

enum BsonReaderException
{
  ILLEGAL_TYPE;
  UNKNOWN_TYPECODE;
  TODO_MODULE;
}

/**
Bson流格式
整个Bson流的长度，单位字节，类型Int32，4字节
----下面一段会重复出现
>下一个键值对的Value类型
>下一个键值对的Key，类型Cstring
>下一个键值对的Value
----
结束标记，0，类型Byte，1字节
**/
class BsonReader
{
  public function new() { }
  
  private static function readBsonValue(buffer:BsonInput, valueTypeCode:Int8):JsonStream return
  {
    switch(valueTypeCode)
    {
      case 0x01: // Double
      {
        JsonStream.NUMBER(buffer.readDouble());
      }
      case 0x02: // String
      {
        var str:String = buffer.readString();
        JsonStream.STRING(str);
      }
      case 0x03: // BSONDocument
      {
        readBsonStream(buffer);
      }
      case 0x04: // array
      {
        JsonStream.ARRAY(new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
        {
          var arrayBufferLength = buffer.readInt();
          var arrayBuffer = buffer.slice(arrayBufferLength - 4);
          buffer.discard(arrayBufferLength - 4);
          var lastLabel:Int = -1;
          while (arrayBuffer.readable() > 1)
          {     
            var code:Int8 = arrayBuffer.readByte();
            var label:Int = Std.parseInt(arrayBuffer.readCString());
            while (++lastLabel < label)
            {
              yield(JsonStream.NULL).async();
            }
            yield(readBsonValue(arrayBuffer, code)).async();
          }
        })));
      }
      case 0x05: // BSONBinary // Binary data ReactiveMongo代码中有TODO注释
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      case 0x06: // BSONUndefined // undefined, 已经被BSON标准弃用
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }     
      case 0x07: // BSONObjectID // objectid,
      {
        var i:Int = -1;
        while (++i < 12)
        {
          buffer.readByte();
        }
        JsonStream.NULL;
      }
      case 0x08: // Boolean // boolean
      {
        buffer.readByte() == 1 ? JsonStream.TRUE:JsonStream.FALSE;
      }
      case 0x09: // DateTime // datetime, UTC datetime in a 64-Int
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      case 0x0A: // Null // null
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      case 0x0B: // regex
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      case 0x0C: // BSONDBPointer // dbpointer 已经被BSON标准弃用
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      case 0x0D: // BSONJavaScript // JS
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      case 0x0E: // BSONSymbol // symbol
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      case 0x0F: // BSONJavaScriptWS // JS with scope
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      case 0x10: // Int
      {
        JsonStream.NUMBER(buffer.readInt());
      }
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      case 0x11: // BSONTimestamp // timestamp,
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      case 0x12: // Long // long, 64-Int
      {
        throw BsonReaderException.TODO_MODULE;//TODO
      }
      case 0xFF: // min key Special type which compares lower than all other possible BSON element values.
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      case 0x7F: // max key Special type which compares higher than all other possible BSON element values.
      {
        throw BsonReaderException.ILLEGAL_TYPE;
      }
      
      default: throw BsonReaderException.UNKNOWN_TYPECODE;
    }
  }
  
  public static function readBsonStream(input:BsonInput):JsonStream return 
  {
    JsonStream.OBJECT(
    {
      new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStreamPair>):Void
      {
        var length = input.readInt();
        //此时bsonBufferEnd已经被读入，而bson长度中包括了bsonBufferEnd的4个字节.
        //如此相加之后这4个字节被额外重复计算了一次，所以实际结束位置需要减去4字节。
        var buffer = input.slice(length - 4);
        input.discard(length - 4);
        while (buffer.readable() > 1)
        {
          var valueTypeCode:Int8 = buffer.readByte();
          var key:String = buffer.readCString();
          yield(new JsonStreamPair(key, readBsonValue(buffer, valueTypeCode))).async();
        }
      }));
    });
  }
}