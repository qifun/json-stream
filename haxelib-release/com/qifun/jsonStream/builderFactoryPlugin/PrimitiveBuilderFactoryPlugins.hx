package com.qifun.jsonStream.builderFactoryPlugin;

import com.dongxiguo.continuation.Continuation;
import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonBuilderFactory;
import haxe.Int64;
#if macro
import haxe.macro.Expr;
#end

@:final
class Int64BuilderFactoryPlugin
{

  public static function asynchronousDeserialize(stream:JsonBuilderFactoryPluginStream<Int64>, onComplete:Null<Int64>->Void):Void
  {
    Continuation.cpsFunction(function(stream:AsynchronousJsonStream):Null<Int64> return
    {
      switch (stream)
      {
        case ARRAY(read):
          switch (read().async())
          {
            case null:
              throw JsonBuilderError.NOT_ENOUGH_FIELDS(read, 2, 0);
            case NUMBER(high):
              switch (read().async())
              {
                case null:
                  throw JsonBuilderError.NOT_ENOUGH_FIELDS(read, 2, 1);
                case NUMBER(low):
                  if (read().async() != null)
                  {
                    throw JsonBuilderError.TOO_MANY_FIELDS(read, 2);
                  }
                  else
                  {
                    Int64.make(cast high, cast low);
                  }
                case stream:
                  throw JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "NUMBER" ]);
              }
            case stream:
              throw JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "NUMBER" ]);
          }
        case NULL:
          null;
        case stream:
          throw JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY", "NULL" ]);
      }
    })(stream.underlying, onComplete);
  }

}

@:final
class IntBuilderFactoryPlugin
{
  public static function asynchronousDeserialize(stream:JsonBuilderFactoryPluginStream<Int>, onComplete:Null<Int>->Void):Void
  {
    Continuation.cpsFunction(function(stream:AsynchronousJsonStream):Null<Int> return
    {
      switch (stream)
      {
        case NUMBER(value):
          cast value;
        case NULL:
          null;
        case _:
          throw JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "NUMBER", "NULL" ]);
      }
    })(stream.underlying, onComplete);
  }
}

@:final
class UIntBuilderFactoryPlugin
{
  public static function asynchronousDeserialize(stream:JsonBuilderFactoryPluginStream<UInt>, onComplete:Null<UInt>->Void):Void
  {
    Continuation.cpsFunction(function(stream:AsynchronousJsonStream):Null<UInt> return
    {
      switch (stream)
      {
        case NUMBER(value):
          cast value;
        case NULL:
          null;
        case _:
          throw JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "NUMBER", "NULL" ]);
      }
    })(stream.underlying, onComplete);
  }
}

#if (java || cs)


@:final
class SingleBuilderFactoryPlugin
{
  public static function asynchronousDeserialize(stream:JsonBuilderFactoryPluginStream<Single>, onComplete:Null<Single>->Void):Void
  {
    Continuation.cpsFunction(function(stream:AsynchronousJsonStream):Null<Single> return
    {
      switch (stream)
      {
        case NUMBER(value):
          cast value;
        case NULL:
          null;
        case _:
          throw JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "NUMBER", "NULL" ]);
      }
    })(stream.underlying, onComplete);
  }
}


#end


@:final
class FloatBuilderFactoryPlugin
{
  public static function asynchronousDeserialize(stream:JsonBuilderFactoryPluginStream<Float>, onComplete:Null<Float>->Void):Void
  {
    Continuation.cpsFunction(function(stream:AsynchronousJsonStream):Null<Float> return
    {
      switch (stream)
      {
        case NUMBER(value):
          cast value;
        case NULL:
          null;
        case _:
          throw JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "NUMBER", "NULL" ]);
      }
    })(stream.underlying, onComplete);
  }
}


@:final
class BoolBuilderFactoryPlugin
{
  public static function asynchronousDeserialize(stream:JsonBuilderFactoryPluginStream<Bool>, onComplete:Null<Bool>->Void):Void
  {
    Continuation.cpsFunction(function(stream:AsynchronousJsonStream):Null<Bool> return
    {
      switch (stream)
      {
        case FALSE: false;
        case TRUE: true;
        case NULL: null;
        case _:
          throw JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "FALSE", "TRUE", "NULL" ]);
      }
    })(stream.underlying, onComplete);
  }
}


@:final
class StringBuilderFactoryPlugin
{
  public static function asynchronousDeserialize(stream:JsonBuilderFactoryPluginStream<String>, onComplete:Null<String>->Void):Void
  {
    Continuation.cpsFunction(function(stream:AsynchronousJsonStream):Null<String> return
    {
      switch (stream)
      {
        case STRING(value):
          value;
        case NULL:
          null;
        case _:
          throw JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "STRING", "NULL" ]);
      }
    })(stream.underlying, onComplete);
  }
}


@:final
class ArrayBuilderFactoryPlugin
{

  @:dox(hide)
  public static function asynchronousDeserializeForElement<Element>(stream:JsonBuilderFactoryPluginStream<Array<Element>>, elementDeserializeFunction:JsonBuilderFactoryPluginStream<Element>->(Element->Void)->Void, onComplete:Null<Array<Element>>->Void):Void return
  {
    Continuation.cpsFunction(function(stream:AsynchronousJsonStream):Array<Element> return
    {
      switch (stream)
      {
        case ARRAY(read):
          var result = [];
          var element = read().async();
          while (element != null)
          {
            result.push(elementDeserializeFunction(new JsonBuilderFactoryPluginStream(element)).async());
            element = read().async();
          }
          result;
        case NULL:
          null;
        case _:
          throw JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY", "NULL" ]);
      }
    })(stream.underlying, onComplete);
  }

  macro public static function asynchronousDeserialize<Element>(stream:haxe.macro.Expr.ExprOf<JsonBuilderFactoryPluginStream<Array<Element>>>, onComplete:haxe.macro.Expr.ExprOf<Null<Array<Element>>->Void>):haxe.macro.Expr.ExprOf<Void>
  {
    macro com.qifun.jsonStream.deserializerPlugin.PrimitiveDeserializerPlugins.ArrayDeserializerPlugin.asynchronousDeserializeForElement($stream, function(substream, onElementComplete) { return substream.pluginDeserialize(onElementComplete); }, onComplete);
  }
}
