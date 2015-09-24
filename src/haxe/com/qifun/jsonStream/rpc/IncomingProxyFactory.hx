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

import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonStream;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import haxe.macro.Type;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonSerializer;
using Lambda;
#end

class IncomingProxyFactory
{

  #if macro

  private static function processName(sb:StringBuf, s:String):Void
  {
    var i = 0;
    while (true)
    {
      var prev = i;
      var found = s.indexOf("_", prev);
      if (found != -1)
      {
        sb.addSub(s, prev, found - prev);
        sb.add("__");
        i = found + 1;
      }
      else
      {
        sb.addSub(s, prev);
        break;
      }
    }
  }

  static function proxyMethodName(pack:Array<String>, name:String):String
  {
    var sb = new StringBuf();
    sb.add("incomingProxy_");
    for (p in pack)
    {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }


  private static function withDefaultTypeParameters(
    body:Expr,
    typeParameters:Array<TypeParameter>):Expr return
  {
    if (typeParameters.empty())
    {
      return body;
    }
    else
    {
      var declear = {
        pos: body.pos,
        expr: EFunction(
          "inline_withDefaultTypeParameters",
          {
            params:
            [
              for (typeParameter in typeParameters)
              {
                name: typeParameter.name,
                // TODO: constraits
              }
            ],
            args: [],
            ret: null,
            expr: macro $body,
          }),
      }
      macro
      {
        $declear;
        withDefaultTypeParameters();
      }
    }
  }

  private static function buildVoidSwitchExprForService(
    serviceClassType:ClassType,
    serviceParameters,
    rpcMethodName: ExprOf<String>,
    parameters:ExprOf<JsonStream>):Expr
  {
    var cases:Array<Case> = [];
    for (field in serviceClassType.fields.get())
    {
      function buildCase(methodKind:MethodKind, args:Array<{ name : String, opt : Bool, t : Type }>):Case return
      {
        var methodName = field.name;
        var numRequestArguments = args.length;

        function parseRestRequest(readArray:Expr, argumentIndex:Int):Expr return
        {
          if (argumentIndex < numRequestArguments)
          {
            var requestType = TypeTools.applyTypeParameters(
              args[argumentIndex].t,
              serviceClassType.params,
              serviceParameters);
            var complexRequestType = TypeTools.toComplexType(requestType);
            var requestName = "request" + argumentIndex;
            var next = parseRestRequest(readArray, argumentIndex + 1);
            macro
            {
              if ($readArray.hasNext())
              {
                var elementStream = $readArray.next();
                var $requestName:$complexRequestType = new com.qifun.jsonStream.JsonDeserializer.JsonDeserializerPluginStream<$complexRequestType>(elementStream).pluginDeserialize();
                $next;
              }
              else
              {
                throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.NOT_ENOUGH_FIELDS($readArray, $v{numRequestArguments}, $v{argumentIndex});
              }
            }
          }
          else
          {
            var parameters =
            [
              for (i in 0...numRequestArguments)
              {
                var requestName = "request" + i;
                macro $i{requestName};
              }
            ];
            macro
            {
              if ($readArray.hasNext())
              {
                throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.TOO_MANY_FIELDS($readArray, $v{numRequestArguments});
              }
              else
              {
                serviceImplementation.$methodName($a{parameters});
              }
            }
          }
        }

        var readIteratorExpr = parseRestRequest(macro readRequest, 0);
        var readGeneratorExpr = parseRestRequest(macro readRequestGenerator, 0);
        var parseRequestExpr =
          withDefaultTypeParameters(
            macro
            {
              var readRequestGenerator = Std.instance(readRequest, (com.dongxiguo.continuation.utils.Generator:Class<com.dongxiguo.continuation.utils.Generator<com.qifun.jsonStream.JsonStream>>));
              if (readRequestGenerator != null)
              {
                $readGeneratorExpr;
              }
              else
              {
                $readIteratorExpr;
              }
            },
            field.params);

        {
          values: [ macro $v{methodName} ],
          expr: macro switch($parameters)
          {
            case com.qifun.jsonStream.JsonStream.ARRAY(readRequest):
            {
              $parseRequestExpr;
            }
            case _:
            {
              throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.UNMATCHED_JSON_TYPE(request, [ "ARRAY" ]);
            }
          }
        };
      };
      switch (field)
      {
        case { kind: FVar(_) | FMethod(MethMacro) }: continue;
        case { kind: FMethod(methodKind), type: TFun(args, Context.follow(_) => TAbstract(_.get() => { module: "com.qifun.jsonStream.rpc.Future", name: "Future0"}, [ ])) } :
        {
          continue;
        }
        case { kind: FMethod(methodKind), type: TFun(args, Context.follow(_) => TAbstract(_.get() => { module: "com.qifun.jsonStream.rpc.Future", name: "Future1"}, [ awaitResultType ])) }:
        {
          continue;
        }
        case { kind: FMethod(methodKind), type: TFun(args, Context.follow(_) => TAbstract(_.get() => { pack: [], name: "Void"}, [ ])) } :
        {
          cases.push(buildCase(methodKind, args));
        }
        case _: throw "Expect method!";
      }
    }
    //trace(ExprTools.toString({
      //expr: ESwitch(rpcMethodName, cases, null),
      //pos: Context.currentPos(),
    //}));
    return
    {
      expr: ESwitch(rpcMethodName, cases, macro throw com.qifun.jsonStream.rpc.IncomingProxyFactory.IncomingProxyError.UNKNOWN_RPC_METHOD(rpcMethodName)),
      pos: Context.currentPos(),
    };
  }

  private static function buildSwitchExprForService(
    serviceClassType:ClassType,
    serviceParameters,
    rpcMethodName: ExprOf<String>,
    parameters:ExprOf<JsonStream>):Expr
  {
    var cases:Array<Case> = [];
    for (field in serviceClassType.fields.get())
    {
      function buildCase(methodKind:MethodKind, args:Array<{ name : String, opt : Bool, t : Type }>, awaitResultType:Null<Type>):Case return
      {
        var methodName = field.name;
        var numRequestArguments = args.length;
        var declareResponseHandler = if (awaitResultType == null)
        {
          macro function():Void responseHandler.onSuccess(com.qifun.jsonStream.JsonStream.NULL);
        }
        else
        {
          var responseType = awaitResultType == null ? null : TypeTools.applyTypeParameters(awaitResultType, serviceClassType.params, serviceParameters);
          var complexResponseType = responseType == null ? null : TypeTools.toComplexType(responseType);
          {
            pos: Context.currentPos(),
            expr: EFunction(
              null,
              {
                args:
                [
                  {
                    name: "response",
                    type: complexResponseType,
                  }
                ],
                ret: null,
                expr: macro responseHandler.onSuccess(
                  new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData<$complexResponseType>(
                    response).pluginSerialize()),
              }),
          }
        }

        function parseRestRequest(readArray:Expr, argumentIndex:Int):Expr return
        {
          if (argumentIndex < numRequestArguments)
          {
            var requestType = TypeTools.applyTypeParameters(
              args[argumentIndex].t,
              serviceClassType.params,
              serviceParameters);
            var complexRequestType = TypeTools.toComplexType(requestType);
            var requestName = "request" + argumentIndex;
            var next = parseRestRequest(readArray, argumentIndex + 1);
            macro
            {
              if ($readArray.hasNext())
              {
                var elementStream = $readArray.next();
                var $requestName:$complexRequestType = new com.qifun.jsonStream.JsonDeserializer.JsonDeserializerPluginStream<$complexRequestType>(elementStream).pluginDeserialize();
                $next;
              }
              else
              {
                throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.NOT_ENOUGH_FIELDS($readArray, $v{numRequestArguments}, $v{argumentIndex});
              }
            }
          }
          else
          {
            var parameters =
            [
              for (i in 0...numRequestArguments)
              {
                var requestName = "request" + i;
                macro $i{requestName};
              }
            ];
            macro
            {
              if ($readArray.hasNext())
              {
                throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.TOO_MANY_FIELDS($readArray, $v{numRequestArguments});
              }
              else
              {
                serviceImplementation.$methodName($a{parameters}).start(
                  $declareResponseHandler,
                  function(errorResponse:Dynamic):Void
                  {
                    responseHandler.onFailure(com.qifun.jsonStream.JsonSerializer.serialize(errorResponse));
                  });
              }
            }
          }
        }

        var readIteratorExpr = parseRestRequest(macro readRequest, 0);
        var readGeneratorExpr = parseRestRequest(macro readRequestGenerator, 0);
        var parseRequestExpr =
          withDefaultTypeParameters(
            macro
            {
              var readRequestGenerator = Std.instance(readRequest, (com.dongxiguo.continuation.utils.Generator:Class<com.dongxiguo.continuation.utils.Generator<com.qifun.jsonStream.JsonStream>>));
              if (readRequestGenerator != null)
              {
                $readGeneratorExpr;
              }
              else
              {
                $readIteratorExpr;
              }
            },
            field.params);

        {
          values: [ macro $v{methodName} ],
          expr: macro switch($parameters)
          {
            case com.qifun.jsonStream.JsonStream.ARRAY(readRequest):
            {
              $parseRequestExpr;
            }
            case _:
            {
              throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.UNMATCHED_JSON_TYPE(request, [ "ARRAY" ]);
            }
          }
        };
      };
      switch (field)
      {
        case { kind: FVar(_) | FMethod(MethMacro) }: continue;
        case { kind: FMethod(methodKind), type: TFun(args, Context.follow(_) => TAbstract(_.get() => { module: "com.qifun.jsonStream.rpc.Future", name: "Future0"}, [ ])) } :
        {
          cases.push(buildCase(methodKind, args, null));
        }
        case { kind: FMethod(methodKind), type: TFun(args, Context.follow(_) => TAbstract(_.get() => { module: "com.qifun.jsonStream.rpc.Future", name: "Future1"}, [ awaitResultType ])) }:
        {
          cases.push(buildCase(methodKind, args, awaitResultType));
        }
        case { kind: FMethod(methodKind), type: TFun(args, Context.follow(_) => TAbstract(_.get() => { pack: [], name: "Void"}, [ ])) } :
        {
          continue;
        }
        case _: throw "Expect method!";
      }
    }
    //trace(ExprTools.toString({
      //expr: ESwitch(rpcMethodName, cases, null),
      //pos: Context.currentPos(),
    //}));
    return
    {
      expr: ESwitch(rpcMethodName, cases, macro throw com.qifun.jsonStream.rpc.IncomingProxyFactory.IncomingProxyError.UNKNOWN_RPC_METHOD(rpcMethodName)),
      pos: Context.currentPos(),
    };
  }

  static function incomingProxyField(serviceClassType:ClassType):Field return
  {
    var typeParameters =
    [
      for (p in serviceClassType.params)
      {
        TPType(TPath({ pack: [], name: p.name }));
      }
    ];
    var typeParameterDeclarations:Array<TypeParamDecl> =
    [
      for (p in serviceClassType.params)
      {
        name: p.name,
        // TODO: Constraits
      }
    ];
    var serviceModule = serviceClassType.module;
    var methodBody = if (Context.defined("doc_gen"))
    {
      macro return ((throw "For documentation generation only!"):com.qifun.jsonStream.rpc.IJsonService);
    }
    else
    {
      var parameterTypes = [ for (p in serviceClassType.params) p.t ];
      var switchRpcMethodName =
        buildSwitchExprForService(serviceClassType, parameterTypes, macro rpcMethodName, macro parameters);
      var switchVoidMethodName =
        buildVoidSwitchExprForService(serviceClassType, parameterTypes, macro rpcMethodName, macro parameters);
      macro return new com.qifun.jsonStream.rpc.IncomingProxy(
        function(request:com.qifun.jsonStream.JsonStream):Void
        {
          switch (request)
          {
            case com.qifun.jsonStream.JsonStream.OBJECT(pairs):
            {
              com.qifun.jsonStream.rpc.IncomingProxyFactory.IncomingProxyRuntime.optimizedExtract1(
                pairs,
                function(pair:com.qifun.jsonStream.JsonStream.JsonStreamPair):Void
                {
                  var rpcMethodName = pair.key;
                  var parameters = pair.value;
                  $switchVoidMethodName;
                });
            }
            case _:
            {
              com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.UNMATCHED_JSON_TYPE(
                request,
                [ "OBJECT" ]);
            }
          }

        },
        function(
          request:com.qifun.jsonStream.JsonStream,
          responseHandler:com.qifun.jsonStream.rpc.IJsonService.IJsonResponseHandler):Void
        {
          switch (request)
          {
            case com.qifun.jsonStream.JsonStream.OBJECT(pairs):
            {
              com.qifun.jsonStream.rpc.IncomingProxyFactory.IncomingProxyRuntime.optimizedExtract1(
                pairs,
                function(pair:com.qifun.jsonStream.JsonStream.JsonStreamPair):Void
                {
                  var rpcMethodName = pair.key;
                  var parameters = pair.value;
                  $switchRpcMethodName;
                });
            }
            case _:
            {
              com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.UNMATCHED_JSON_TYPE(
                request,
                [ "OBJECT" ]);
            }
          }
        });
    }

    {
      name: proxyMethodName(serviceClassType.pack, serviceClassType.name),
      access: [ AStatic, APublic ],
      pos: Context.currentPos(),
      kind: FFun(
        {
          params: typeParameterDeclarations,
          args:
          [
            {
              name: "serviceImplementation",
              type: TPath(
                {
                  pack: serviceClassType.pack,
                  name: serviceModule.substring(serviceModule.lastIndexOf(".") + 1),
                  sub: serviceClassType.name,
                  params: typeParameters,
                }),
            }
          ],
          ret: null,
          expr: methodBody,
        }),
    }
  }

  #end


  @:noUsing
  macro public static function generateIncomingProxyFactory(includeModules:Array<String>):Array<Field> return
  {
    var fields = Context.getBuildFields();
    for (moduleName in includeModules)
    {
      for (rootType in Context.getModule(moduleName))
      {
        switch (rootType)
        {
          case TInst(_.get() => classType, args) if (classType.isInterface):
          {
            fields.push(incomingProxyField(classType));
          }
          default:
        }
      }
    }
    fields;
  }
}

@:dox(hide)
class IncomingProxyRuntime
{

  @:extern
  @:noUsing
  private static inline function extract1<Element>(iterator:Iterator<Element>, handler:Element->Void):Void
  {
    if (iterator.hasNext())
    {
      var element = iterator.next();
      handler(element);
      if (iterator.hasNext())
      {
        throw JsonDeserializer.JsonDeserializerError.TOO_MANY_FIELDS(iterator, 1);
      }
    }
    else
    {
      throw JsonDeserializer.JsonDeserializerError.NOT_ENOUGH_FIELDS(iterator, 1, 0);
    }
  }

  @:extern
  @:noUsing
  public static inline function optimizedExtract1<Element>(iterator:Iterator<Element>, handler:Element->Void):Void
  {
    var generator:Generator<Element> = Std.instance(iterator, (Generator:Class<Generator<Element>>));
    if (generator == null)
    {
      extract1(iterator, handler);
    }
    else
    {
      extract1(generator, handler);
    }
  }

}

enum IncomingProxyError
{
  UNKNOWN_RPC_METHOD(rpcMethodName:String);
}
