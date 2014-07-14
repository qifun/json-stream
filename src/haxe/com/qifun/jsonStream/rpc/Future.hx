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
class HaxeToScalaForeachFunction<AwaitResult>
extends AbstractFunction2<Function1<AwaitResult, BoxedUnit>, PartialFunction<Throwable, BoxedUnit>, BoxedUnit>
{

  var HaxeToScalaForeachFunction:(AwaitResult->Void)->Catcher->Void;

  public function new(HaxeToScalaForeachFunction:(AwaitResult->Void)->Catcher->Void)
  {
    super();
    this.HaxeToScalaForeachFunction = HaxeToScalaForeachFunction;
  }

  override function apply(handler:Function1<AwaitResult, BoxedUnit>, catcher:PartialFunction<Throwable, BoxedUnit>):BoxedUnit
  {
    HaxeToScalaForeachFunction(
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
#if (!doc_gen)
@:genericBuild(com.qifun.jsonStream.rpc.Future.FutureTypeResolver.futureTypeByHandler())
#end
extern class Future<Handler> { }

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

  #if doc_gen
  macro public static function start<Handler>(future:ExprOf<Future<Handler>>, completeHandler:ExprOf<Handler>, errorHandler:ExprOf<Catcher>):ExprOf<Void>
  {
    return throw "For documentation generation only!";
  }

  macro public static function newFuture<Handler>(startFunction:ExprOf<Handler->Catcher->Void>):ExprOf<Future<Handler>>
  {
    return throw "For documentation generation only!";
  }
  #else
  macro public static function newFuture<Handler, Tuple>(startFunction:ExprOf<Handler->Catcher->Void>):ExprOf<NativeFuture<Tuple>>
  {
    if (Context.defined("stateless_future") && Context.defined("java"))
    {
      switch (Context.follow(Context.typeof(startFunction)))
      {
        case TFun([{t: TFun(args, _)}, _], _):
        {
          var tupleArguments = [ for (arg in args) arg.t ];
          var tupledFunctionExpr = untupled(tupleArguments, macro tupleHandler);
          var tupleTypePath = getTupleTypePath(tupleArguments);
          var tupleComplexType = TPath(tupleTypePath);
          return macro
          {
            function haxeForeach(tupleHandler:$tupleComplexType->Void, catcher:Dynamic->Void):Void
            {
              $startFunction($tupledFunctionExpr, catcher);
            }
            // 此处由于Haxe bugs，所以必须加上Dynamic
            var scalaForeach:Dynamic = new com.qifun.jsonStream.rpc.Future.HaxeToScalaForeachFunction(haxeForeach);
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

  macro public static function start<Handler, Tuple>(future:ExprOf<NativeFuture<Tuple>>, completeHandler:ExprOf<Handler>, errorHandler:ExprOf<Catcher>):ExprOf<Void>
  {
    if (Context.defined("stateless_future") && Context.defined("java"))
    {
      switch (Context.follow(Context.typeof(future)))
      {
        case TInst(
          _,
          [
            Context.follow(_) => TInst(_, params),
            _
          ]):
        {
          var tupledFunctionPath =
          {
            pack: [ "com", "qifun", "jsonStream", "rpc" ],
            name: "Future",
            sub: 'TupledFunction${params.length}'
          }
          return macro $future.foreach(cast new $tupledFunctionPath($completeHandler), new com.qifun.jsonStream.rpc.Future.HaxeToScalaCatcher($errorHandler));
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
  #end

}

@:dox(hide) class FutureTypeResolver
{

  #if stateless_future
  #if macro

  @:noUsing
  public static function getAwaitResultTypes(futureType:Type):Array<Type>
  {
    switch (Context.follow(futureType))
    {
      case TInst(
        _, // Awaitable
        [
          TInst(
            _, // TupleN
            awaitResultTypes
          ),
          _, //BoxedUnit
        ]):
        return awaitResultTypes;
      default:
        throw "Expect com.qifun.statelessFuture.Awaitable";
    }
  }

  private static function tupleTypePath(args:Array<{ t : haxe.macro.Type, opt : Bool, name : String }>):TypePath return
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
      params: [for (arg in args) TPType(TypeTools.toComplexType(arg.t)) ],
    }
  }
  #end

  @:noUsing
  macro public static function futureTypeByHandler():Type
  {
    switch (Context.getLocalType())
    {
      case TInst(_, [ Context.follow(_) => handlerType ]):
      {
        switch (handlerType)
        {
          case TFun(
            args,
            Context.follow(_) => TAbstract(
              _.get() => { pack: [], name: "Void", },
              [])):
            return ComplexTypeTools.toType(
              TPath(
                {
                  pack: [ "com", "qifun", "jsonStream", "rpc" ],
                  name: "Future",
                  sub: "NativeFuture",
                  params:
                  [
                    TPType(TPath(tupleTypePath(args))),
                  ]
                }));
          case a:
          {
            return Context.error('Expect Future<?->Void>, actually $a', Context.currentPos());
          }
        }
      }
      case a:
      {
        return Context.error('Expect Future<?->Void>, actually $a', Context.currentPos());
      }
    }
  }
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

@:dox(hide) typedef NativeFuture<AwaitResult> = com.qifun.statelessFuture.Awaitable<AwaitResult, BoxedUnit>;

private typedef Tuple0 = BoxedUnit;

@:dox(hide) @:final class TupledFunction0<Return> extends AbstractFunction1<Tuple0, Return>
{
  var underlying:Void->Return;
  public function new(underlying:Void->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple0):Return return underlying();
}

@:dox(hide) @:final class TupledFunction1<Argument0, Return> extends AbstractFunction1<Tuple1<Argument0>, Return>
{
  var underlying:Argument0->Return;
  public function new(underlying:Argument0->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple1<Argument0>):Return return underlying(tuple._1());
}

@:dox(hide) @:final class TupledFunction2<Argument0, Argument1, Return> extends AbstractFunction1<Tuple2<Argument0, Argument1>, Return>
{
  var underlying:Argument0->Argument1->Return;
  public function new(underlying:Argument0->Argument1->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple2<Argument0, Argument1>):Return return underlying(tuple._1(), tuple._2());
}

@:dox(hide) @:final class TupledFunction3<Argument0, Argument1, Argument2, Return> extends AbstractFunction1<Tuple3<Argument0, Argument1, Argument2>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple3<Argument0, Argument1, Argument2>):Return return underlying(tuple._1(), tuple._2(), tuple._3());
}

@:dox(hide) @:final class TupledFunction4<Argument0, Argument1, Argument2, Argument3, Return> extends AbstractFunction1<Tuple4<Argument0, Argument1, Argument2, Argument3>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple4<Argument0, Argument1, Argument2, Argument3>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4());
}

@:dox(hide) @:final class TupledFunction5<Argument0, Argument1, Argument2, Argument3, Argument4, Return> extends AbstractFunction1<Tuple5<Argument0, Argument1, Argument2, Argument3, Argument4>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple5<Argument0, Argument1, Argument2, Argument3, Argument4>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5());
}

@:dox(hide) @:final class TupledFunction6<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Return> extends AbstractFunction1<Tuple6<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple6<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6());
}

@:dox(hide) @:final class TupledFunction7<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Return> extends AbstractFunction1<Tuple7<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple7<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7());
}

@:dox(hide) @:final class TupledFunction8<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Return> extends AbstractFunction1<Tuple8<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple8<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8());
}

@:dox(hide) @:final class TupledFunction9<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Return> extends AbstractFunction1<Tuple9<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple9<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9());
}

@:dox(hide) @:final class TupledFunction10<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Return> extends AbstractFunction1<Tuple10<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple10<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10());
}

@:dox(hide) @:final class TupledFunction11<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Return> extends AbstractFunction1<Tuple11<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple11<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11());
}

@:dox(hide) @:final class TupledFunction12<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Return> extends AbstractFunction1<Tuple12<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple12<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11(), tuple._12());
}

@:dox(hide) @:final class TupledFunction13<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Return> extends AbstractFunction1<Tuple13<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple13<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11(), tuple._12(), tuple._13());
}

@:dox(hide) @:final class TupledFunction14<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Return> extends AbstractFunction1<Tuple14<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple14<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11(), tuple._12(), tuple._13(), tuple._14());
}

@:dox(hide) @:final class TupledFunction15<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Return> extends AbstractFunction1<Tuple15<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple15<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11(), tuple._12(), tuple._13(), tuple._14(), tuple._15());
}

@:dox(hide) @:final class TupledFunction16<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Return> extends AbstractFunction1<Tuple16<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple16<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11(), tuple._12(), tuple._13(), tuple._14(), tuple._15(), tuple._16());
}

@:dox(hide) @:final class TupledFunction17<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Return> extends AbstractFunction1<Tuple17<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple17<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11(), tuple._12(), tuple._13(), tuple._14(), tuple._15(), tuple._16(), tuple._17());
}

@:dox(hide) @:final class TupledFunction18<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Return> extends AbstractFunction1<Tuple18<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Argument17->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Argument17->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple18<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11(), tuple._12(), tuple._13(), tuple._14(), tuple._15(), tuple._16(), tuple._17(), tuple._18());
}

@:dox(hide) @:final class TupledFunction19<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18, Return> extends AbstractFunction1<Tuple19<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Argument17->Argument18->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Argument17->Argument18->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple19<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11(), tuple._12(), tuple._13(), tuple._14(), tuple._15(), tuple._16(), tuple._17(), tuple._18(), tuple._19());
}

@:dox(hide) @:final class TupledFunction20<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18, Argument19, Return> extends AbstractFunction1<Tuple20<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18, Argument19>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Argument17->Argument18->Argument19->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Argument17->Argument18->Argument19->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple20<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18, Argument19>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11(), tuple._12(), tuple._13(), tuple._14(), tuple._15(), tuple._16(), tuple._17(), tuple._18(), tuple._19(), tuple._20());
}

@:dox(hide) @:final class TupledFunction21<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18, Argument19, Argument20, Return> extends AbstractFunction1<Tuple21<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18, Argument19, Argument20>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Argument17->Argument18->Argument19->Argument20->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Argument17->Argument18->Argument19->Argument20->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple21<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18, Argument19, Argument20>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11(), tuple._12(), tuple._13(), tuple._14(), tuple._15(), tuple._16(), tuple._17(), tuple._18(), tuple._19(), tuple._20(), tuple._21());
}

@:dox(hide) @:final class TupledFunction22<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18, Argument19, Argument20, Argument21, Return> extends AbstractFunction1<Tuple22<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18, Argument19, Argument20, Argument21>, Return>
{
  var underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Argument17->Argument18->Argument19->Argument20->Argument21->Return;
  public function new(underlying:Argument0->Argument1->Argument2->Argument3->Argument4->Argument5->Argument6->Argument7->Argument8->Argument9->Argument10->Argument11->Argument12->Argument13->Argument14->Argument15->Argument16->Argument17->Argument18->Argument19->Argument20->Argument21->Return) { super(); this.underlying = underlying; }
  override public function apply(tuple:Tuple22<Argument0, Argument1, Argument2, Argument3, Argument4, Argument5, Argument6, Argument7, Argument8, Argument9, Argument10, Argument11, Argument12, Argument13, Argument14, Argument15, Argument16, Argument17, Argument18, Argument19, Argument20, Argument21>):Return return underlying(tuple._1(), tuple._2(), tuple._3(), tuple._4(), tuple._5(), tuple._6(), tuple._7(), tuple._8(), tuple._9(), tuple._10(), tuple._11(), tuple._12(), tuple._13(), tuple._14(), tuple._15(), tuple._16(), tuple._17(), tuple._18(), tuple._19(), tuple._20(), tuple._21(), tuple._22());
}


#end
#end

