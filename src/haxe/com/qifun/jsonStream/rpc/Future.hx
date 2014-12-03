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

package com.qifun.jsonStream.rpc;

import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;

typedef Catcher = Dynamic->Void;

/**
  跨平台的异步任务。

  @param Handler 任务完成时调用的回调函数类型。
**/
#if cs

@:dox(hide)
abstract Future0(dotnet.system.Action2<dotnet.system.Action, cs.system.Action_1<Dynamic>>)
{

  public function new(startFunction:(Void->Void)->Catcher->Void):Future0
  {
    this = cast untyped __delegate__(
      function(handler:dotnet.system.Action, catcher:cs.system.Action_1<Dynamic>):Void
        startFunction(
          function () handler.Invoke(),
          function (e:Dynamic) catcher.Invoke(e)));
  }

  public function start(completeHandler:Void->Void, errorHandler:Catcher):Void
  {
    this.Invoke(cast untyped __delegate__(function()completeHandler()), cs.system.Action_1.FromHaxeFunction(function(e:Dynamic)errorHandler(e)));
  }

}

@:dox(hide)
abstract Future1<AwaitResult>(dotnet.system.Action2<cs.system.Action_1<AwaitResult>, cs.system.Action_1<Dynamic>>)
{

  public inline function new(startFunction:(AwaitResult->Void)->Catcher->Void)
  {
    this = cast untyped __delegate__(
      function(handler:cs.system.Action_1<AwaitResult>, catcher:cs.system.Action_1<Dynamic>):Void
        startFunction(
          function (r:AwaitResult) handler.Invoke(r),
          function (e:Dynamic) catcher.Invoke(e)));
  }

  public function start(completeHandler:AwaitResult->Void, errorHandler:Catcher):Void
  {
    this.Invoke(cs.system.Action_1.FromHaxeFunction(function(r)completeHandler(r)), cs.system.Action_1.FromHaxeFunction(function(e:Dynamic)errorHandler(e)));
  }
}

#else

@:dox(hide)
abstract Future0(IFuture0)
{

  public function new(startFunction:(Void->Void)->Catcher->Void):Future0
  {
    this = new FunctionFuture0(startFunction);
  }

  public function start(completeHandler:Void->Void, errorHandler:Catcher):Void
  {
    this.start(new FunctionCompleteHandler0(completeHandler, errorHandler));
  }

}

@:dox(hide)
abstract Future1<AwaitResult>(IFuture1<AwaitResult>)
{

  public inline function new(startFunction:(AwaitResult->Void)->Catcher->Void)
  {
    this = new FunctionFuture1(startFunction);
  }

  public function start(completeHandler:AwaitResult->Void, errorHandler:Catcher):Void
  {
    this.start(new FunctionCompleteHandler1<AwaitResult>(completeHandler, errorHandler));
  }

}

@:dox(hide)
@:nativeGen
interface ICompleteHandler0
{
  function onSuccess():Void;
  function onFailure(error:Dynamic):Void;
}

@:dox(hide)
@:nativeGen
interface ICompleteHandler1<AwaitResult>
{
  function onSuccess(awaitResult:AwaitResult):Void;
  function onFailure(error:Dynamic):Void;
}

@:dox(hide)
@:nativeGen
interface ICatcher
{
  function apply(error:Dynamic):Void;
}

@:dox(hide)
@:nativeGen
interface IFuture1<AwaitResult>
{
  function start(handler:ICompleteHandler1<AwaitResult>):Void;
}

@:dox(hide)
@:nativeGen
interface IFuture0
{
  function start(handler:ICompleteHandler0):Void;
}

@:final
private class FunctionCompleteHandler0 implements ICompleteHandler0
{

  var onSuccessFunction:Void->Void;
  public function onSuccess():Void
  {
    onSuccessFunction();
  }

  var onFailureFunction:Catcher;
  public function onFailure(error:Dynamic):Void
  {
    onFailureFunction(error);
  }

  public inline function new(onSuccessFunction:Void->Void, onFailureFunction:Catcher)
  {
    this.onSuccessFunction = onSuccessFunction;
    this.onFailureFunction = onFailureFunction;
  }

}

@:final
private class FunctionCompleteHandler1<AwaitResult> implements ICompleteHandler1<AwaitResult>
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
private class FunctionFuture0 implements IFuture0
{

  var startFunction:(Void->Void)->Catcher->Void;

  public inline function new(startFunction:(Void->Void)->Catcher->Void)
  {
    this.startFunction = startFunction;
  }

  public inline function start(handler:ICompleteHandler0):Void
  {
    startFunction(handler.onSuccess.bind(), handler.onFailure.bind());
  }

}

@:final
private class FunctionFuture1<AwaitResult> implements IFuture1<AwaitResult>
{

  var startFunction:(AwaitResult->Void)->Catcher->Void;

  public inline function new(startFunction:(AwaitResult->Void)->Catcher->Void)
  {
    this.startFunction = startFunction;
  }

  public inline function start(handler:ICompleteHandler1<AwaitResult>):Void
  {
    startFunction(handler.onSuccess.bind(), handler.onFailure.bind());
  }

}

#end

@:genericBuild(com.qifun.jsonStream.rpc.Future.FutureBuilder.build())
class Future<AwaitResult>
{
}

@:dox(hide)
class FutureBuilder
{
  macro public static function build():ComplexType return
  {
    switch (Context.getLocalType())
    {
      case TInst(_.get() => { name: "Future", module: "com.qifun.jsonStream.rpc.Future", }, [ parameterType ]):
      {
        if (parameterType.match(TAbstract(_.get() => { name: "Void", pack: [], }, [])))
        {
          macro : com.qifun.jsonStream.rpc.Future.Future0;
        }
        else
        {
          var parameterComplexType = TypeTools.toComplexType(parameterType);
          macro : com.qifun.jsonStream.rpc.Future.Future1<$parameterComplexType>;
        }
      }
      default:
      {
        Context.error("Expect Future<AwaitResult>", Context.currentPos());
      }
    }
  }

}
