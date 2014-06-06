package com.qifun.jsonStream.builderPlugin;

import com.dongxiguo.continuation.Continuation;
import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonBuilderFactory;
import haxe.Int64;
#if macro
import haxe.macro.Expr;
#end

@:final
class Int64BuilderPlugin
{

  public static function pluginBuild(stream:JsonBuilderPluginStream<Int64>, onComplete:Null<Int64>->Void):Void
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
class UIntBuilderPlugin
{
  public static
  #if (!cs && !java) inline #end // Workaround
  function pluginBuild(stream:JsonBuilderPluginStream<UInt>, onComplete:Null<UInt>->Void):Void
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
          throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "NUMBER", "NULL" ]);
      }
    })(stream.underlying, onComplete);
  }
}

@:final
class IntBuilderPlugin
{
  public static
  #if (!cs && !java) inline #end // Workaround
  function pluginBuild(stream:JsonBuilderPluginStream<Int>, onComplete:Null<Int>->Void):Void
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
          throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "NUMBER", "NULL" ]);
      }
    })(stream.underlying, onComplete);
  }
}

#if (java || cs)


@:final
class SingleBuilderPlugin
{
  public static function pluginBuild(stream:JsonBuilderPluginStream<Single>, onComplete:Null<Single>->Void):Void
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
class FloatBuilderPlugin
{
  public static function pluginBuild(stream:JsonBuilderPluginStream<Float>, onComplete:Null<Float>->Void):Void
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
class BoolBuilderPlugin
{
  public static function pluginBuild(stream:JsonBuilderPluginStream<Bool>, onComplete:Null<Bool>->Void):Void
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
class StringBuilderPlugin
{
  public static function pluginBuild(stream:JsonBuilderPluginStream<String>, onComplete:Null<String>->Void):Void
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
class ArrayBuilderPlugin
{

  @:dox(hide)
  public static function buildForElement<Element>(stream:JsonBuilderPluginStream<Array<Element>>, elementDeserializeFunction:JsonBuilderPluginStream<Element>->(Element->Void)->Void, onComplete:Null<Array<Element>>->Void):Void
  {
    Continuation.cpsFunction(function(stream:AsynchronousJsonStream):Array<Element> return
    {
      switch (stream)
      {
        case ARRAY(read):
          var result = [];
          var element = null;
          while ((element = read().async()) != null)
          {
            result.push(elementDeserializeFunction(new JsonBuilderPluginStream(element)).async());
          }
          result;
        case NULL:
          null;
        case _:
          throw JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "ARRAY", "NULL" ]);
      }
    })(stream.underlying, onComplete);
  }

  macro public static function pluginBuild<Element>(stream:haxe.macro.Expr.ExprOf<JsonBuilderPluginStream<Array<Element>>>, onComplete:haxe.macro.Expr.ExprOf<Null<Array<Element>>->Void>):haxe.macro.Expr.ExprOf<Void> return
  {
    macro com.qifun.jsonStream.builderPlugin.PrimitiveBuilderPlugins.ArrayBuilderPlugin.buildForElement($stream, function(substream, onElementComplete) { return substream.pluginBuild(onElementComplete); }, $onComplete);
  }
}
