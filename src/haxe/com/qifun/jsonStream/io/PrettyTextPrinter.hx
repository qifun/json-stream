package com.qifun.jsonStream.io ;
import com.qifun.jsonStream.JsonStream.JsonStreamPair;
import com.dongxiguo.continuation.utils.Generator;
import com.dongxiguo.continuation.Continuation;
import haxe.format.JsonPrinter;
import haxe.io.Output;
import haxe.Int64;
import haxe.Json;

class PrettyTextPrinter
{

  static function printIndent(output:Output, indent:Int)
  {
    for (i in 0...indent)
    {
      output.writeByte("\t".code);
    }
  }

  static inline function printString(output:Output, value:String):Void
  {
    // TODO: 优化性能
    output.writeString(Json.stringify(value));
  }

  static inline function printNumber(output:Output, value:Float):Void
  {
    // TODO: 优化性能
    output.writeString(Json.stringify(value));
  }

  static function printPair(output:Output, pair:JsonStreamPair, indent:Int):Void
  {
    printIndent(output, indent);
    printString(output, pair.key);
    output.writeByte(":".code);
    output.writeByte(" ".code);
    print(output, pair.value, indent);
  }

  public static function print(output:Output, value:JsonStream, indent:Int = 0):Void
  {
    switch (value)
    {
      case STRING(value):
      {
        printString(output, value);
      }
      case NUMBER(value):
      {
        printNumber(output, value);
      }
      case OBJECT(iterator):
      {
        output.writeByte("{".code);
        var innerIdent = indent + 1;
        if (iterator.hasNext())
        {
          output.writeByte("\n".code);
          printPair(output, iterator.next(), innerIdent);
          for (pair in iterator)
          {
            output.writeByte(",".code);
            output.writeByte("\n".code);
            printPair(output, pair, innerIdent);
          }
          output.writeByte("\n".code);
          printIndent(output, indent);
        }
        else
        {
          output.writeByte(" ".code);
        }
        output.writeByte("}".code);
      }
      case ARRAY(iterator):
      {
        output.writeByte("[".code);
        var innerIdent = indent + 1;
        if (iterator.hasNext())
        {
          output.writeByte("\n".code);
          printIndent(output, innerIdent);
          print(output, iterator.next(), innerIdent);
          for (element in iterator)
          {
            output.writeByte(",".code);
            output.writeByte("\n".code);
            printIndent(output, innerIdent);
            print(output, element, innerIdent);
          }
          output.writeByte("\n".code);
          printIndent(output, indent);
        }
        else
        {
          output.writeByte(" ".code);
        }
        output.writeByte("]".code);
      }
      case TRUE:
      {
        output.writeString("true");
      }
      case FALSE:
      {
        output.writeString("false");
      }
      case NULL:
      {
        output.writeString("null");
      }
      case INT32(value):
      {
        output.writeString(Json.stringify(value));
      }
      case INT64(high, low):
      {
        output.writeString(Int64.toStr(Int64.make(high, low)));
      }
      case BINARY(value):
      {
        output.writeString(value.toHex());
      }
    }
  }

  public static function toString(value:JsonStream):String return
  {
    var output = new haxe.io.BytesOutput();
    print(output, value, 0);
    output.getBytes().toString();
  }
}
