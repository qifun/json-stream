package com.qifun.jsonStream.rpc;

import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;
#if stateless_future
#if java
import scala.runtime.*;
import scala.*;
import java.lang.Throwable;
#end
#end


typedef Catcher = Dynamic->Void;

#if stateless_future
#if java

@:dox(hide)
@:final
class HaxeToScalaOnCompleteFunction<AwaitResult>
extends AbstractFunction1<AwaitResult, BoxedUnit>
{
  var underlying:AwaitResult->Void;

  public inline function new(underlying:AwaitResult->Void)
  {
    super();
    this.underlying = underlying;
  }

  override function apply(result:AwaitResult):BoxedUnit
  {
    underlying(result);
    return BoxedUnit.UNIT;
  }


}


@:dox(hide)
class HaxeToScalaForeachFunction<AwaitResult>
extends AbstractFunction2<Function1<AwaitResult, BoxedUnit>, PartialFunction<Throwable, BoxedUnit>, BoxedUnit>
{

  var underlying:(AwaitResult->Void)->Catcher->Void;

  public inline function new(underlying:(AwaitResult->Void)->Catcher->Void)
  {
    super();
    this.underlying = underlying;
  }

  override function apply(handler:Function1<AwaitResult, BoxedUnit>, catcher:PartialFunction<Throwable, BoxedUnit>):BoxedUnit
  {
    underlying(
      function(result):Void
      {
        handler.apply(result);
      },
      function(e):Void
      {
        if (catcher.isDefinedAt(e))
        {
          catcher.apply(e);
        }
        else
        {
          scala.util.control.Exception.allCatcher().apply(e);
        }
      });
    return BoxedUnit.UNIT;
  }

}
#end
#end



/**
  跨平台的异步任务。

  @param Handler 任务完成时调用的回调函数类型。
**/
#if (stateless_future && java)
typedef NativeFuture<AwaitResult> = com.qifun.statelessFuture.Awaitable<AwaitResult, BoxedUnit>;
#else

@:dox(hide)
interface ICompleteHandler<AwaitResult>
{
  function onSuccess(awaitResult:AwaitResult):Void;
  function onFailure(error:Dynamic):Void;
}

@:dox(hide)
interface ICatcher
{
  function apply(error:Dynamic):Void;
}

@:dox(hide)
interface IFuture<AwaitResult>
{
  function start(handler:ICompleteHandler<AwaitResult>):Void;
}

@:final
private class FunctionCompleteHandler<AwaitResult> implements ICompleteHandler<AwaitResult>
{

  var onSuccessFunction:AwaitResult->Void;
  public function onSuccess(awaitResult:AwaitResult):Void
  {
    onSuccessFunction(awaitResult);
  }

  var onFailureFunction:Catcher;
  public function onFailure(error:Dynamic):Void
  {
    onFailureFunction(error);
  }

  public inline function new(onSuccessFunction:AwaitResult->Void, onFailureFunction:Catcher)
  {
    this.onSuccessFunction = onSuccessFunction;
    this.onFailureFunction = onFailureFunction;
  }

}

@:final
private class FunctionFuture<AwaitResult> implements IFuture<AwaitResult>
{

  var startFunction:(AwaitResult->Void)->Catcher->Void;

  public inline function new(startFunction:(AwaitResult->Void)->Catcher->Void)
  {
    this.startFunction = startFunction;
  }

  public inline function start(handler:ICompleteHandler<AwaitResult>):Void
  {
    startFunction(handler.onSuccess.bind(), handler.onFailure.bind());
  }

}

typedef NativeFuture<AwaitResult> = IFuture<AwaitResult>;
#end

abstract Future<AwaitResult>(NativeFuture<AwaitResult>)
{

  public inline function new(startFunction:(AwaitResult->Void)->Catcher->Void)
  {
    #if (stateless_future && java)
    // 此处由于Haxe bugs，所以必须加上untyped
    this = untyped new com.qifun.statelessFuture.util.FunctionFuture(
      untyped new HaxeToScalaForeachFunction(
        function(tupleHandler:AwaitResult->Void, catcher:Dynamic->Void):Void
          startFunction(tupleHandler, catcher)));
    #else
    this = new FunctionFuture(startFunction);
    #end
  }

  public inline function start<AwaitResult>(
    completeHandler:AwaitResult->Void,
    errorHandler:Catcher):Void
  {
    #if (stateless_future && java)
    // 此处由于Haxe bugs，所以必须加上untyped
    this.foreach(
      untyped new com.qifun.jsonStream.rpc.Future.HaxeToScalaOnCompleteFunction(completeHandler),
      new com.qifun.jsonStream.rpc.Future.HaxeToScalaCatcher(errorHandler));
    #else
    this.start(new FunctionCompleteHandler(completeHandler, errorHandler));
    #end
  }

}

#if stateless_future
#if java

@:dox(hide)
@:final
class HaxeToScalaCatcher extends AbstractPartialFunction<java.lang.Throwable, BoxedUnit>
{

  var underlying:Catcher;
  public inline function new(underlying:Catcher)
  {
    super();
    this.underlying = underlying;
  }

  @:overload
  override public function apply(e:java.lang.Throwable):BoxedUnit
  {
    underlying(e);
    return BoxedUnit.UNIT;
  }

  @:overload
  override public function isDefinedAt(e:java.lang.Throwable):Bool
  {
    return true;
  }

}

#end
#end

