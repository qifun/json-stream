package com.qifun.jsonStream.io;

import haxe.Constraints.Function;
import haxe.Int64;
import haxe.io.BytesBuffer;
import haxe.io.Input;
import haxe.io.Output;
import haxe.io.Eof;
import haxe.Json;
import com.dongxiguo.continuation.utils.Generator;
import com.dongxiguo.continuation.Continuation;
import com.qifun.jsonStream.JsonStream;

enum BsonReaderError
{
  UNSUPPORT_BSON_TYPE(typeCode:BsonInput, expected:Array<String>);
  EXCEPT_BINARY_TYPECODE(typeCode:Int, expected:Array<String>);
  UNMATCHED_JSON_TYPE(stream:JsonStream, expected:Array<String>);
  UNMATCHED_BSON_TYPE(buffer:BsonInput, expected:Array<String>);
}

/**
    Bson流格式

    整个Bson流的长度，单位字节，类型Int32，4字节

    下面一段会重复出现

    >下一个键值对的Value类型
    
    >下一个键值对的Key，类型Cstring
    
    >下一个键值对的Value
    
    结束标记，0，类型Byte，1字节
**/
class BsonReader

{
  public function new() { }
  
  #if java
  private static function readBsonValue(buffer:BsonInput, valueTypeCode:java.types.Int8):JsonStream return
  #else
  private static function readBsonValue(buffer:BsonInput, valueTypeCode:Int):JsonStream return
  #end
  {
    switch(valueTypeCode)
    {
      case 0x01: // Double
      {
        JsonStream.NUMBER(buffer.readDouble());
      }
      case 0x02: // String
      {
        JsonStream.STRING(buffer.readString());
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
            var code = arrayBuffer.readByte();
            var label:Int = Std.parseInt(arrayBuffer.readCString());
            while (++lastLabel < label)
            {
              yield(JsonStream.NULL).async();
            }
            yield(readBsonValue(arrayBuffer, code)).async();
          }
        })));
      }
      case 0x05: // BSONBinary 
      {
        var binaryLength = buffer.readInt();
        //1位type码
        var typeCode = buffer.readByte();
        #if java
        var tmp = new java.lang.Byte(buffer.readByte());
        var typeCode = tmp.intValue();
        #else
        var typeCode = buffer.readByte();
        #end
        if (typeCode != 0x00)
          throw BsonReaderError.EXCEPT_BINARY_TYPECODE(typeCode, ["TYPE CODE SHOULD BE 0x00"]);
        var bytesBuffer:BytesBuffer = new BytesBuffer();
        var i:Int = -1;
        while (++i < binaryLength)
        {
          #if java
          var byte = new java.lang.Byte(buffer.readByte());
          bytesBuffer.addByte(byte.intValue());
          #else
          bytesBuffer.addByte(buffer.readByte());
          #end
        }
        JsonStream.BINARY(bytesBuffer.getBytes());
      }
      case 0x06: // BSONUndefined // undefined, 已经被BSON标准弃用
      {
        throw BsonReaderError.UNSUPPORT_BSON_TYPE(buffer, ["TYPECODE: 0x06", "TYPE: BSONUndefined"]);
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
        throw BsonReaderError.UNSUPPORT_BSON_TYPE(buffer, ["TYPECODE: 0x09", "TYPE: DateTime"]);
      }
      case 0x0A: // Null // null
      {
        JsonStream.NULL;
      }
      case 0x0B: // regex
      {
        throw BsonReaderError.UNSUPPORT_BSON_TYPE(buffer, ["TYPECODE: 0x0B", "TYPE: BSONRegex"]);
      }
      case 0x0C: // BSONDBPointer // dbpointer 已经被BSON标准弃用
      {
        throw BsonReaderError.UNSUPPORT_BSON_TYPE(buffer, ["TYPECODE: 0x0C", "TYPE: BSONDBPointer"]);
      }
      case 0x0D: // BSONJavaScript // JS
      {
        throw BsonReaderError.UNSUPPORT_BSON_TYPE(buffer, ["TYPECODE: 0x0D", "TYPE: BSONJavaScript"]);
      }
      case 0x0E: // BSONSymbol // symbol
      {
        throw BsonReaderError.UNSUPPORT_BSON_TYPE(buffer, ["TYPECODE: 0x0E", "TYPE: BSONSymbol"]);
      }
      case 0x0F: // BSONJavaScriptWS // JS with scope
      {
        throw BsonReaderError.UNSUPPORT_BSON_TYPE(buffer, ["TYPECODE: 0x0F", "TYPE: BSONJavaScriptWithScope"]);
      }
      case 0x10: // Int
      {
        JsonStream.INT32(buffer.readInt());
      }
      case 0x11: // BSONTimestamp // timestamp,
      {
        throw BsonReaderError.UNSUPPORT_BSON_TYPE(buffer, ["TYPECODE: 0x11", "TYPE: BSONTimeStamp"]);
      }
      case 0x12: // Long // long, 64-Int
      {
        var tmp:haxe.Int64 = buffer.readLong();
        JsonStream.INT64(Int64.getHigh(tmp), Int64.getLow(tmp));
      }
      case 0xFF: // min key Special type which compares lower than all other possible BSON element values.
      {
        throw BsonReaderError.UNSUPPORT_BSON_TYPE(buffer, ["TYPECODE: 0xFF", "TYPE: MinKey"]);
      }
      case 0x7F: // max key Special type which compares higher than all other possible BSON element values.
      {
        throw BsonReaderError.UNSUPPORT_BSON_TYPE(buffer, ["TYPECODE: 0x7F", "TYPE: MaxKey"]);
      }
      default:
      {
        #if java
        var errorTypeCodeString = java.lang.Byte._toString(valueTypeCode);
        #else
        var errorTypeCodeString = Std.string(valueTypeCode);
        #end
        throw BsonReaderError.UNMATCHED_BSON_TYPE(buffer, ["UNMATCHED BSON TYPE CODE", errorTypeCodeString]);
      }
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
          var valueTypeCode = buffer.readByte();
          var key:String = buffer.readCString();
          yield(new JsonStreamPair(key, readBsonValue(buffer, valueTypeCode))).async();
        }
      }));
    });
  }
}