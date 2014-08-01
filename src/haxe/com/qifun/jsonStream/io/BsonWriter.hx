package com.qifun.jsonStream.io;

#if java

import com.dongxiguo.continuation.utils.Generator;
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

enum BsonWriterError
{
  /**
   
  **/
  UNMATCHED_JSON_TYPE(stream:JsonStream);
}

class BsonWriter
{
  public function new() { }

  //TODO 支持所有类型
  public static function writeBsonObject(output:BsonOutput, pairs:Iterator<JsonStreamPair>):Void
  {

        var now:Int = output.index();
        output.writeInt(0);
        var generator = Std.instance(pairs, (Generator:Class<Generator<JsonStreamPair>>));
        if (generator == null)
        {
          for (pair in pairs)
          {
            writePair(output, pair.key, pair.value);
          }
        }
        else
        {
          for (pair in generator)
          {
            writePair(output, pair.key, pair.value);
          }
        }
        output.setInt(now, (output.index() - now + 1));
        output.writeByte(0x00);
  }
  
  private static function writePair(output:BsonOutput, key:String, value:JsonStream):Void
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
        output.writeDouble(Std.parseFloat(Json.stringify(value)));
      }
      case OBJECT(iterator):
      { 
        output.writeByte(0x03);
        output.writeCString(key);
        writeBsonObject(output, iterator);
        /*
        var now:Int = output.index();
        output.writeInt(0);
        var generator = Std.instance(iterator, (Generator:Class<Generator<JsonStreamPair>>));
        if (generator == null)
        {
          for (pair in iterator)
          {
            writePair(output, pair.key, pair.value);
          }
        }
        else
        {
          for (pair in generator)
          {
            writePair(output, pair.key, pair.value);
          }
        }
        output.setInt(now, (output.index() - now + 1));
        output.writeByte(0x00);
        */
      }
      case ARRAY(iterator):
      {
        output.writeByte(0x04);
        output.writeCString(key);
        var now:Int = output.index();
        output.writeInt(0);
        var i = -1;
        var generator = Std.instance(iterator, (Generator:Class<Generator<JsonStream>>));
        if (generator == null)
        {
          for (element in iterator)
          {
            ++i;
            if (element == JsonStream.NULL)
              continue;
            writePair(output, Std.string(i), element);
          }
        }
        else
        {
          for (element in iterator)
          {
            ++i;
            if (element == JsonStream.NULL)
              continue;
            writePair(output, Std.string(i), element);
          }
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
      case INT32(value):
      {
        output.writeByte(0x10);
        output.writeCString(key);
        output.writeInt(Std.parseInt(Json.stringify(value)));
      }
      case INT64(high, low):
      {
        output.writeByte(0x12);
        output.writeCString(key);
        output.writeLong(Int64.make(high, low));
      }
      case BINARY(value):
      {
        output.writeByte(0x05);
        output.writeCString(key);
        output.writeInt(value.length);
        output.writeByte(0x00);//Binary type code
        var i:Int = -1;
        while (++i < value.length)
        {
          output.writeByte(value.get(i));
        }
      }
      default:
      {
        throw BsonWriterError.UNMATCHED_JSON_TYPE(value);
      }
    }
  }
}
#end
