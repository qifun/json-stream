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

package com.qifun.jsonStream.deserializerPlugin;

import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.JsonDeserializer;
import haxe.crypto.Base64;
import haxe.ds.Vector;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.macro.Context;
import haxe.macro.TypeTools;

@:final
class Int64DeserializerPlugin
{

  @:extern
  @:noUsing
  private static inline function extractInt64(iterator:Iterator<JsonStream>):Int64 return
  {
    if (iterator.hasNext())
    {
      var element0 = iterator.next();
      switch (element0)
      {
        case NUMBER(high):
        {
          if (iterator.hasNext())
          {
            var element1 = iterator.next();
            switch (element1)
            {
              case NUMBER(low):
                if (iterator.hasNext())
                {
                  throw JsonDeserializerError.TOO_MANY_FIELDS(iterator, 2);
                }
                else
                {
                  Int64.make(cast high, cast low);
                }
              case _:
                throw JsonDeserializerError.UNMATCHED_JSON_TYPE(element1, [ "NUMBER" ]);
            }
          }
          else
          {
            throw JsonDeserializerError.NOT_ENOUGH_FIELDS(iterator, 2, 1);
          }
        }
        case _:
        {
          throw JsonDeserializerError.UNMATCHED_JSON_TYPE(element0, [ "NUMBER" ]);
        }
      }
    }
    else
    {
      throw JsonDeserializerError.NOT_ENOUGH_FIELDS(iterator, 2, 0);
    }
  }

  @:extern
  @:noUsing
  private static inline function optimizedExtractInt64(iterator:Iterator<JsonStream>):Int64 return
  {
    var generator = Std.instance(iterator, (Generator:Class<Generator<JsonStream>>));
    if (generator == null)
    {
      extractInt64(iterator);
    }
    else
    {
      extractInt64(generator);
    }
  }

  public static function pluginDeserialize(self:JsonDeserializerPluginStream<Int64>):Null<Int64> return
  {
    switch (self.underlying)
    {
      case ARRAY(elements):
      {
        optimizedExtractInt64(elements);
      }
      case INT64(high, low):
      {
        Int64.make(high, low);
      }
      case NULL:
        null;
      case stream:
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY", "NULL"]);
    }
  }
}

@:final
class UIntDeserializerPlugin
{
  public static function pluginDeserialize(self:JsonDeserializerPluginStream<UInt>):Null<UInt> return
  {
    switch (self.underlying)
    {
      case com.qifun.jsonStream.JsonStream.NUMBER(value):
        cast value;
      case NULL:
        null;
      case stream:
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY", "NULL"]);
    }
  }
}


@:final
class IntDeserializerPlugin
{
  public static function pluginDeserialize(self:JsonDeserializerPluginStream<Int>):Null<Int> return
  {
    switch (self.underlying)
    {
      case NUMBER(value):
        cast value;
      case INT32(value):
      {
        value;
      }
      case NULL:
        null;
      case stream:
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY", "NULL"]);
    }
  }
}

#if (java || cs)
  @:final
  class SingleDeserializerPlugin
  {
    public static function pluginDeserialize(self:JsonDeserializerPluginStream<Single>):Null<Single> return
    {
      switch (self.underlying)
      {
        case com.qifun.jsonStream.JsonStream.NUMBER(value):
          value;
        case NULL:
          null;
        case stream:
          throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY", "NULL"]);
      }
    }
  }
#end

@:final
class FloatDeserializerPlugin
{
  public static function pluginDeserialize(self:JsonDeserializerPluginStream<Float>):Null<Float> return
  {
    switch (self.underlying)
    {
      case com.qifun.jsonStream.JsonStream.NUMBER(value):
        value;
      case NULL:
        null;
      case stream:
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY", "NULL"]);
    }
  }
}

@:final
class BoolDeserializerPlugin
{
  public static function pluginDeserialize(self:JsonDeserializerPluginStream<Bool>):Null<Bool> return
  {
    switch (self.underlying)
    {
      case com.qifun.jsonStream.JsonStream.FALSE: false;
      case com.qifun.jsonStream.JsonStream.TRUE: true;
      case NULL: null;
      case stream:
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "FALSE", "TRUE", "NULL"]);
    }
  }
}

@:final
class BinaryDeserializerPlugin
{
  public static function pluginDeserialize(self:JsonDeserializerPluginStream<Bytes>):Null<Bytes> return
  {

    switch (self.underlying)
    {
      case BINARY(value):
      {
        value;
      }
      case STRING(value):
      {
         Base64.decode(value);
      }
      case NULL:
        null;
      case stream:
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "BINARY", "NULL"]);
    }
  }
}

@:final
class StringDeserializerPlugin
{
  public static function pluginDeserialize(self:JsonDeserializerPluginStream<String>):Null<String> return
  {
    switch (self.underlying)
    {
      case com.qifun.jsonStream.JsonStream.STRING(value):
        value;
      case NULL:
        null;
      case stream:
        throw JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "STRING", "NULL"]);
    }
  }
}

@:final
class ArrayDeserializerPlugin
{

  @:noUsing
  @:dox(hide)
  public static function deserializeForElement<Element>(stream:JsonDeserializerPluginStream<Array<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<Array<Element>> return
  {
    switch (stream.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(value):
        var generator = Std.instance(value, (Generator:Class<Generator<JsonStream>>));
        if (generator != null)
        {
          [
            for (element in generator)
            {
              elementDeserializeFunction(new JsonDeserializerPluginStream(element));
            }
          ];
        }
        else
        {
          [
            for (element in value)
            {
              elementDeserializeFunction(new JsonDeserializerPluginStream(element));
            }
          ];
        }
      case NULL:
        null;
      case _:
        throw "Expect array";
    }
  }

  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<Array<Element>>>):ExprOf<Null<Array<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.ArrayDeserializerPlugin.deserializeForElement($self, function(substream) return substream.pluginDeserialize());
  }
}

@:final
#if cs
@:nativeGen // Workaround for https://github.com/HaxeFoundation/haxe/issues/3302
#end
class VectorDeserializerPlugin
{

  @:noUsing
  @:dox(hide)
  public static function deserializeForElement<Element>(self:JsonDeserializerPluginStream<Vector<Element>>, elementDeserializeFunction:JsonDeserializerPluginStream<Element>->Element):Null<Vector<Element>> return
  {
    switch (self.underlying)
    {
      case com.qifun.jsonStream.JsonStream.ARRAY(value):
        var generator = Std.instance(value, (Generator:Class<Generator<JsonStream>>));
        if (generator != null)
        {
          Vector.fromArrayCopy(
            [
              for (element in generator)
              {
                elementDeserializeFunction(new JsonDeserializerPluginStream(element));
              }
            ]);
        }
        else
        {
          Vector.fromArrayCopy(
            [
              for (element in value)
              {
                elementDeserializeFunction(new JsonDeserializerPluginStream(element));
              }
            ]);
        }
      case NULL:
        null;
      case _:
        throw "Expect Vector";
    }
  }

  macro public static function pluginDeserialize<Element>(self:ExprOf<JsonDeserializerPluginStream<Vector<Element>>>):ExprOf<Null<Vector<Element>>> return
  {
    macro com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.VectorDeserializerPlugin.deserializeForElement($self, function(substream) return substream.pluginDeserialize());
  }
}

//TODO : StringMap and IntMap
