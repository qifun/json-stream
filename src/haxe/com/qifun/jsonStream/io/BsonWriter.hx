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

enum BsonWriterException
{
  ILLEGAL_JSONOBJECT;
  ILLEGAL_JSONSTREAM;
}

class BsonWriter
{
  public function new() { }
  /**
  只有一个完整的BSON文档才能解析为Bson流
  **/
  public static function writeBsonStream(output:BsonOutput, value:JsonStream):Void
  {
    switch (value)
    {
      case OBJECT(iterator):
      {
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
      }
      default:
      {
        throw BsonWriterException.ILLEGAL_JSONOBJECT;
      }
    }
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
      default:
      {
        throw BsonWriterException.ILLEGAL_JSONSTREAM;
      }
    }
  }
}