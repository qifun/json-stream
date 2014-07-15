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

  public function new(underlying:AwaitResult->Void)
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

  public function new(underlying:(AwaitResult->Void)->Catcher->Void)
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
typedef Future<AwaitResult> = com.qifun.statelessFuture.Awaitable<AwaitResult, BoxedUnit>;
#else
typedef Future<AwaitResult> = { }
#end

@:final class FutureHelper
{

  #if stateless_future

  #if macro
  private static function getTupleTypePath(args:Array<Type>):TypePath return
  {
    if (args.length == 0)
    {
      pack: [ "scala", "runtime" ],
      name: "BoxedUnit",
    }
    else
    {
      pack: [ "scala" ],
      name: 'Tuple${args.length}',
      params: [for (arg in args) TPType(TypeTools.toComplexType(arg)) ],
    }
  }

  private static function untupled<Tuple>(tupleArguments:Array<Type>, tupleFunction:ExprOf<Tuple->Void>):Expr
  {
    var argDefinitions:Array<FunctionArg> = [];
    var argExprs = [];
    for (i in 0...tupleArguments.length)
    {
      var tupleArgument = tupleArguments[i];
      var name = '__tupleArgument$i';
      argDefinitions.push({
        name: name,
        type: TypeTools.toComplexType(tupleArgument),
      });
      argExprs.push(macro $i{name});
    }
    var tupleTypePath = getTupleTypePath(tupleArguments);
    return
    {
      pos: tupleFunction.pos,
      expr: EFunction(
        null,
        {
          args: argDefinitions,
          ret: null,
          expr: macro $tupleFunction(new $tupleTypePath($a{argExprs})),
        })
    };
  }

  #end

  #end

  @:noUsing
  macro public static function newFuture<AwaitResult>(startFunction:ExprOf<(AwaitResult->Void)->Catcher->Void>):ExprOf<Future<AwaitResult>>
  {
    if (Context.defined("stateless_future") && Context.defined("java"))
    {
      switch (Context.follow(Context.typeof(startFunction)))
      {
        case TFun([{t: TFun([ _.t => awaitResultType ], _)}, _], _):
        {
          var awaitResultComplexType = TypeTools.toComplexType(awaitResultType);
          return macro
          {
            // 此处由于Haxe bugs，所以必须加上Dynamic
            var scalaForeach:Dynamic = new com.qifun.jsonStream.rpc.Future.HaxeToScalaForeachFunction(
              function(tupleHandler:$awaitResultComplexType->Void, catcher:Dynamic->Void):Void
                $startFunction(tupleHandler, catcher));
            var future:Dynamic = new com.qifun.statelessFuture.util.FunctionFuture(scalaForeach);
            future;
          }
        }
        default:
        {
          return Context.error("Expect function", startFunction.pos);
        }
      }
    }
    else
    {
      throw "Not implemented";
    }
  }

  @:noUsing
  macro public static function start<AwaitResult>(future:ExprOf<Future<AwaitResult>>, completeHandler:ExprOf<AwaitResult->Void>, errorHandler:ExprOf<Catcher>):ExprOf<Void>
  {
    if (Context.defined("stateless_future") && Context.defined("java"))
    {
      switch (Context.follow(Context.typeof(future)))
      {
        case TInst(
          _,
          [
            Context.follow(_) => awaitResultType,
            _
          ]):
        {
          return macro $future.foreach(
            cast new com.qifun.jsonStream.rpc.Future.HaxeToScalaOnCompleteFunction($completeHandler),
            new com.qifun.jsonStream.rpc.Future.HaxeToScalaCatcher($errorHandler));
        }
        default:
        {
          return Context.error("Expect Future.", Context.currentPos());
        }
      }
    }
    else
    {
      throw "Not implemented";
    }
  }

}

@:dox(hide) class FutureTypeResolver
{

  #if stateless_future
  #if macro

  @:noUsing
  public static function getAwaitResultTypes(futureType:Type):Type
  {
    switch (Context.follow(futureType))
    {
      case TInst(
        _, // Awaitable
        [
          awaitResultType,
          _, //BoxedUnit
        ]):
        return awaitResultType;
      default:
        return Context.error("Expect com.qifun.statelessFuture.Awaitable", Context.currentPos());
    }
  }

  #end

  #end
}


#if stateless_future
#if java

@:dox(hide)
@:final
class HaxeToScalaCatcher extends AbstractPartialFunction<java.lang.Throwable, BoxedUnit>
{

  var underlying:Catcher;
  public function new(underlying:Catcher)
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

