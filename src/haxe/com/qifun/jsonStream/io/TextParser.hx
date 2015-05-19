/*
 * json-stream
 * Copyright 2014 深圳岂凡网络有限公司 (Shenzhen QiFun Network Corp., LTD)
 *
 * Author: 杨博 (Yang Bo) <pop.atry@gmail.com>, 张修羽 (Zhang Xiuyu) <zxiuyu@126.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.qifun.jsonStream.io ;
import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonStream.JsonStreamPair;
import haxe.io.BytesBuffer;
import haxe.io.Eof;
import haxe.io.Input;
import haxe.io.StringInput;

private class TextParseContext
{

  public var level:Int = 0;

  public function new() { }

}

enum TextParserError
{
  ILLEGAL_NUMBER_FORMAT;
  UNKNOWN_IDENTIFY;
  EXPECT_VALUE;
  EXPECT_EOF;
  EXPECT_DOUBLE_QUOTE;
  EXPECT_COLON;
  EXPECT_END_BRACKET;
  INNER_JSON_STREAM_IS_NOT_FINISHED(expectedLevel:Int, currentLevel:Int);
}

class TextParser
{

  static function parseHexCharacter(c:Int):Int return
  {
    switch (c)
    {
      case "0".code: 0;
      case "1".code: 1;
      case "2".code: 2;
      case "3".code: 3;
      case "4".code: 4;
      case "5".code: 5;
      case "6".code: 6;
      case "7".code: 7;
      case "8".code: 8;
      case "9".code: 9;
      case "a".code | "A".code: 0xA;
      case "b".code | "B".code: 0xB;
      case "c".code | "C".code: 0xC;
      case "d".code | "D".code: 0xD;
      case "e".code | "E".code: 0xE;
      case "f".code | "F".code: 0xF;
      default: throw TextParserError.ILLEGAL_NUMBER_FORMAT;
    }
  }

  static function parseHexCharacter4(c0:Int, c1:Int, c2:Int, c3:Int):String
  {
    var h0 = parseHexCharacter(c0);
    var h1 = parseHexCharacter(c1);
    var h2 = parseHexCharacter(c2);
    var h3 = parseHexCharacter(c3);
    return String.fromCharCode((h0 << 24) | (h1 << 16) | (h2 << 8) | h3);
  }

  static function parseStringLiteral(source:ISource, context:TextParseContext):String
  {
    var buffer = new BytesBuffer();
    var b;
    while ( { source.next(); b = source.current; b != "\"".code; } )
    {
      switch (b)
      {
        case "\\".code:
          source.next();
          switch (source.current)
          {
            case "\"".code:
              buffer.addByte("\"".code);
            case "\\".code:
              buffer.addByte("\\".code);
            case "b".code:
              buffer.addByte("\x08".code);
            case "f".code:
              buffer.addByte("\x0C".code);
            case "n".code:
              buffer.addByte("\n".code);
            case "r".code:
              buffer.addByte("\r".code);
            case "t".code:
              buffer.addByte("\t".code);
            case "u".code:
              var c0 = { source.next(); source.current; }
              var c1 = { source.next(); source.current; }
              var c2 = { source.next(); source.current; }
              var c3 = { source.next(); source.current; }
              var s = parseHexCharacter4(c0, c1, c2, c3);
              buffer.addString(s);
          }
        case -1:
          throw new Eof();
        default:
          buffer.addByte(b);
      }
    }
    source.next();
    return buffer.getBytes().toString();
  }

  static function readPositiveInteger(source:ISource, context:TextParseContext, buffer:BytesBuffer):Void
  {
    var digit = source.current;
    if (digit >= "0".code && digit <= "9".code)
    {
      buffer.addByte(digit);
      source.next();
      digit = source.current;
      while (digit >= "0".code && digit <= "9".code)
      {
        buffer.addByte(digit);
        source.next();
        digit = source.current;
      }
    }
    else
    {
      throw TextParserError.ILLEGAL_NUMBER_FORMAT;
    }
  }

  static function readExponent(source:ISource, context:TextParseContext, buffer:BytesBuffer):Void
  {
    switch(source.current)
    {
      case "E".code | "e".code:
      {
        buffer.addByte("E".code);
        source.next();
        var b = source.current;
        switch (b)
        {
          case "-".code, "+".code:
            buffer.addByte(b);
            source.next();
            readPositiveInteger(source, context, buffer);
          default:
            readPositiveInteger(source, context, buffer);
        }
      }
      default:
      {
        return;
      }
    }
  }

  static function readFraction(source:ISource, context:TextParseContext, buffer:BytesBuffer):Void
  {
    if (source.current == ".".code)
    {
      buffer.addByte(".".code);
      source.next();
      readPositiveInteger(source, context, buffer);
    }
    readExponent(source, context, buffer);
  }

  static function readPositiveNumberLiteral(source:ISource, context:TextParseContext, buffer:BytesBuffer):Void
  {
    switch (source.current)
    {
      case "0".code:
      {
        // 整数部分是0，现在读取小数部分
        buffer.addByte("0".code);
        source.next();
        readFraction(source, context, buffer);
      }
      case notZero if (notZero >= "1".code && notZero <= "9".code):
      {
        buffer.addByte(notZero);
        source.next();
        var digit = source.current;
        while (digit >= "0".code && digit <= "9".code)
        {
          buffer.addByte(digit);
          source.next();
          digit = source.current;
        }
        // 整数部分读完了，现在读取小数部分
        readFraction(source, context, buffer);
      }
      default:
      {
        throw TextParserError.ILLEGAL_NUMBER_FORMAT;
      }
    }
  }

  static function skipWhiteSpace(source:ISource, context:TextParseContext):Void
  {
    while (true)
    {
      switch (source.current)
      {
        case "\t".code, "\r".code, "\n".code, " ".code:
        {
          source.next();
        }
        default:
        {
          return;
        }
      }
    }
  }

  static function skipComma(source:ISource, context:TextParseContext):Bool
  {
    if (source.current == ",".code)
    {
      source.next();
      skipWhiteSpace(source, context);
      return true;
    }
    else
    {
      return false;
    }
  }

  static function parseArrayLiteral(source:ISource, context:TextParseContext):Generator<JsonStream>
  {
    return new Generator(Continuation.cpsFunction(function(yield):Void
    {
      var expectedCurrentLevel = ++context.level;
      source.next();
      skipWhiteSpace(source, context);
      if (source.current == "]".code)
      {
        source.next();
      }
      else
      {
        do
        {
          var value = parseValue(source, context);
          @await yield(value);
          if (expectedCurrentLevel != context.level)
          {
            throw TextParserError.INNER_JSON_STREAM_IS_NOT_FINISHED(expectedCurrentLevel, context.level);
          }
          skipWhiteSpace(source, context);
        }
        while (skipComma(source, context));
        if (source.current != "]".code)
        {
          throw TextParserError.EXPECT_END_BRACKET;
          return;
        }
        source.next();
      }
      context.level--;
    }));
  }

  static function parseObjectLiteral(source:ISource, context:TextParseContext):Generator<JsonStreamPair>
  {
    return new Generator(Continuation.cpsFunction(function(yield):Void
    {
      var expectedCurrentLevel = ++context.level;
      source.next();
      skipWhiteSpace(source, context);
      if (source.current == "}".code)
      {
        source.next();
      }
      else
      {
        do
        {
          if (source.current == "\"".code)
          {
            var key = parseStringLiteral(source, context);
            skipWhiteSpace(source, context);
            if (source.current != ":".code)
            {
              throw TextParserError.EXPECT_COLON;
              return;
            }
            source.next();
            skipWhiteSpace(source, context);
            var value = parseValue(source, context);
            @await yield(new JsonStreamPair(key, value));
            if (expectedCurrentLevel != context.level)
            {
              throw TextParserError.INNER_JSON_STREAM_IS_NOT_FINISHED(expectedCurrentLevel, context.level);
            }
            skipWhiteSpace(source, context);
          }
          else
          {
            throw TextParserError.EXPECT_DOUBLE_QUOTE;
            return;
          }
        }
        while (skipComma(source, context));
        if (source.current != "}".code)
        {
          throw TextParserError.EXPECT_END_BRACKET;
          return;
        }
        source.next();
      }
      context.level--;
    }));
  }

  static function parseValue(source:ISource, context:TextParseContext):JsonStream return
  {
    switch (source.current)
    {
      case "\"".code:
        return JsonStream.STRING(parseStringLiteral(source, context));
      case "-".code:
        var buffer = new BytesBuffer();
        buffer.addByte("-".code);
        source.next();
        readPositiveNumberLiteral(source, context, buffer);
        return JsonStream.NUMBER(Std.parseFloat(buffer.getBytes().toString()));
      case digit if (digit >= "0".code && digit <= "9".code):
        var buffer = new BytesBuffer();
        readPositiveNumberLiteral(source, context, buffer);
        return JsonStream.NUMBER(Std.parseFloat(buffer.getBytes().toString()));
      case "{".code:
        return JsonStream.OBJECT(parseObjectLiteral(source, context));
      case "[".code:
        return JsonStream.ARRAY(parseArrayLiteral(source, context));
      case 't'.code:
        if ('r'.code == { source.next(); source.current; })
        if ('u'.code == { source.next(); source.current; })
        if ('e'.code == { source.next(); source.current; })
        {
          source.next();
          return JsonStream.TRUE;
        }
        return throw TextParserError.UNKNOWN_IDENTIFY;
      case 'f'.code:
      {
        if ('a'.code == { source.next(); source.current; })
        if ('l'.code == { source.next(); source.current; })
        if ('s'.code == { source.next(); source.current; })
        if ('e'.code == { source.next(); source.current; })
        {
          source.next();
          return JsonStream.FALSE;
        }
        return throw TextParserError.UNKNOWN_IDENTIFY;
      }
      case 'n'.code:
      {
        if ('u'.code == { source.next(); source.current; })
        if ('l'.code == { source.next(); source.current; })
        if ('l'.code == { source.next(); source.current; })
        {
          source.next();
          return JsonStream.NULL;
        }
        return throw TextParserError.UNKNOWN_IDENTIFY;
      }
      default:
      {
        return throw TextParserError.EXPECT_VALUE;
      }
    }
  }

  public static function parse(source:ISource, context:TextParseContext):JsonStream
  {
    skipWhiteSpace(source, context);
    return parseValue(source, context);
  }

  public static function parseString(string:String):JsonStream
  {
    return parse(new StringSource(string), new TextParseContext());
  }

  public static function parseInput(input:Input):JsonStream
  {
    return parse(new InputSource(input), new TextParseContext());
  }

}

interface ISource
{
  function next():Void;
  function get_current():Int;
  var current(get, never):Int;
}

@:final
class StringSource extends StringInput implements ISource
{
  var head:Int;
  public function next():Void
  {
    try
    {
      head = readByte();
    }
    catch(e:Eof)
    {
      head = -1;
    }
  }

  public function get_current():Int
  {
    return head;
  }

  public var current(get, never):Int;

  public function new(s:String)
  {
    super(s);
    head = readByte();
  }

}

@:final
class InputSource implements ISource
{

  var head:Int;

  var tail:Input;

  public function next():Void
  {
    try
    {
      head = tail.readByte();
    }
    catch(e:Eof)
    {
      head = -1;
    }
  }

  public function get_current():Int
  {
    return head;
  }

  public var current(get, never):Int;

  public function new(input:Input)
  {
    head = input.readByte();
    tail = input;
  }

}
