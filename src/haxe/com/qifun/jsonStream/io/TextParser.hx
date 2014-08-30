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

enum TextParserError
{
  ILLEGAL_NUMBER_FORMAT;
  UNKNOWN_IDENTIFY;
  EXPECT_VALUE;
  EXPECT_EOF;
  EXPECT_DOUBLE_QUOTE;
  EXPECT_COLON;
  EXPECT_END_BRACKET;
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

  static function parseStringLiteral(source:ISource):String
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

  static function parsePositiveInteger(source:ISource):Float
  {
    var digit = source.current;
    if (digit >= "0".code && digit < "9".code)
    {
      var result:Float = digit - "0".code;
      source.next();
      digit = source.current;
      while (digit >= "0".code && digit < "9".code)
      {
        result = result * 10 + (digit - "0".code);
        source.next();
        digit = source.current;
      }
      return result;
    }
    else
    {
      return throw TextParserError.ILLEGAL_NUMBER_FORMAT;
    }
  }

  static function parseExponent(base:Float, source:ISource):Float
  {
    switch(source.current)
    {
      case "E".code | "e".code:
      {
        source.next();
        switch (source.current)
        {
          case "-".code:
            source.next();
            return base * Math.pow(10, -parsePositiveInteger(source));
          case "+".code:
            source.next();
            return base * Math.pow(10, parsePositiveInteger(source));
          default:
            return base * Math.pow(10, parsePositiveInteger(source));
        }
      }
      default:
      {
        return base;
      }
    }
  }

  static function parseFraction(base:Float, source:ISource):Float
  {
    if (source.current == ".".code)
    {
      source.next();
      var digit = source.current;
      if (digit >= "0".code && digit < "9".code)
      {
        var factor = 0.1;
        base += (digit - "0".code) * factor;
        source.next();
        digit = source.current;
        while (digit >= "0".code && digit < "9".code)
        {
          factor *= 0.1;
          base += (digit - "0".code) * factor;
          source.next();
          digit = source.current;
        }
      }
      else
      {
        return throw TextParserError.ILLEGAL_NUMBER_FORMAT;
      }
    }
    return parseExponent(base, source);
  }

  static function parsePositiveNumberLiteral(source:ISource):Float
  {
    switch (source.current)
    {
      case "0".code:
      {
        // 整数部分是0，现在读取小数部分
        source.next();
        return parseFraction(0, source);
      }
      case notZero if (notZero >= "1".code && notZero < "9".code):
      {
        var f:Float = notZero - "0".code;
        source.next();
        var digit = source.current;
        while (digit >= "0".code && digit < "9".code)
        {
          f = f * 10 + (digit - "0".code);
          source.next();
          digit = source.current;
        }
        // 整数部分读完了，现在读取小数部分
        return parseFraction(f, source);
      }
      default:
      {
        return throw TextParserError.ILLEGAL_NUMBER_FORMAT;
      }
    }
  }

  static function skipWhiteSpace(source:ISource):Void
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

  static function skipComma(source:ISource):Bool
  {
    if (source.current == ",".code)
    {
      source.next();
      skipWhiteSpace(source);
      return true;
    }
    else
    {
      return false;
    }
  }

  static function parseArrayLiteral(source:ISource):Generator<JsonStream>
  {
    return new Generator(Continuation.cpsFunction(function(yield):Void
    {
      source.next();
      skipWhiteSpace(source);
      if (source.current == "]".code)
      {
        source.next();
      }
      else
      {
        do
        {
          var value = parseValue(source);
          yield(value).async();
          skipWhiteSpace(source);
        }
        while (skipComma(source));
        if (source.current != "]".code)
        {
          throw TextParserError.EXPECT_END_BRACKET;
          return;
        }
        source.next();
      }
    }));
  }

  static function parseObjectLiteral(source:ISource):Generator<JsonStreamPair>
  {
    return new Generator(Continuation.cpsFunction(function(yield):Void
    {
      source.next();
      skipWhiteSpace(source);
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
            var key = parseStringLiteral(source);
            skipWhiteSpace(source);
            if (source.current != ":".code)
            {
              throw TextParserError.EXPECT_COLON;
              return;
            }
            source.next();
            skipWhiteSpace(source);
            var value = parseValue(source);
            yield(new JsonStreamPair(key, value)).async();
            skipWhiteSpace(source);
          }
          else
          {
            throw TextParserError.EXPECT_DOUBLE_QUOTE;
            return;
          }
        }
        while (skipComma(source));
        if (source.current != "}".code)
        {
          throw TextParserError.EXPECT_END_BRACKET;
          return;
        }
        source.next();
      }
    }));
  }

  static function parseValue(source:ISource):JsonStream return
  {
    switch (source.current)
    {
      case "\"".code:
        return JsonStream.STRING(parseStringLiteral(source));
      case "-".code:
        source.next();
        return JsonStream.NUMBER(-parsePositiveNumberLiteral(source));
      case digit if (digit >= "0".code && digit < "9".code):
        return JsonStream.NUMBER(parsePositiveNumberLiteral(source));
      case "{".code:
        return JsonStream.OBJECT(parseObjectLiteral(source));
      case "[".code:
        return JsonStream.ARRAY(parseArrayLiteral(source));
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

  public static function parse(source:ISource):JsonStream
  {
    skipWhiteSpace(source);
    return parseValue(source);
  }

  public static function parseString(string:String):JsonStream
  {
    return parse(new StringSource(string));
  }

  public static function parseInput(input:Input):JsonStream
  {
    return parse(new InputSource(input));
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
