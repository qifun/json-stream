package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonStream;
#if macro
import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
using Lambda;
#end

@:autoBuild(com.qifun.jsonStream.rpc.IIncomingProxy.IncomingProxyGenerator.build())
interface IIncomingProxy<ServiceInterface>
{
  var service(get, never):ServiceInterface;

  // 由用户实现
  function get_service():ServiceInterface;

  // 由宏实现
  function incomingRpc(request:AsynchronousJsonStream, handler:JsonStream->Void):Void;
}

@:dox(hide)
class IncomingProxyGenerator
{

  #if macro

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

  private static function buildSwitchExprForService(
    serviceClassType:ClassType,
    serviceParameters,
    rpcMethodName: ExprOf<String>,
    parameters:ExprOf<AsynchronousJsonStream>):Expr
  {
    var cases:Array<Case> = [];
    for (field in serviceClassType.fields.get())
    {
      switch (field)
      {
        case { kind: FVar(_) | FMethod(MethMacro) }: continue;
        case { kind: FMethod(methodKind), type: TFun(args, _) }:
        {
          var methodName = field.name;
          var numRequestArguments = args.length - 1;
          var responseHandlerType = args[numRequestArguments];
          var responseTypes = switch (args[numRequestArguments].t)
          {
            case TFun(responseTypes, _): responseTypes;
            case _: throw "Expect TFun";
          }
          var yieldExprs =
          [
            for (i in 0...responseTypes.length)
            {
              var responseType = TypeTools.applyTypeParameters(
                responseTypes[i].t,
                serviceClassType.params,
                serviceParameters);
              var complexResponseType = TypeTools.toComplexType(responseType);
              var responseName = "response" + i;
              macro yield(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData<$complexResponseType>($i{responseName}).pluginSerialize()).async();
            }
          ];
          var yieldBlock =
          {
            pos: Context.currentPos(),
            expr: EBlock(yieldExprs),
          }
          var declareResponseHandler =
          {
            pos: Context.currentPos(),
            expr: EFunction(
              "responseHandler",
              {
                args:
                [
                  for (i in 0...responseTypes.length)
                  {
                    {
                      name: "response" + i,
                      type: null,
                    }
                  }
                ],
                ret: null,
                expr: macro return com.qifun.jsonStream.JsonStream.ARRAY(
                  new com.dongxiguo.continuation.utils.Generator(
                    com.dongxiguo.continuation.Continuation.cpsFunction(
                      function(yield:com.dongxiguo.continuation.utils.Generator.YieldFunction <
                        com.qifun.jsonStream.JsonStream>):Void $yieldBlock))),
              }),
          }
          function parseArguments(readArray:Expr, argumentIndex:Int):Expr return
          {
            if (argumentIndex < numRequestArguments)
            {
              var requestType = TypeTools.applyTypeParameters(
                args[argumentIndex].t,
                serviceClassType.params,
                serviceParameters);
              var complexRequestType = TypeTools.toComplexType(requestType);
              var requestName = "request" + argumentIndex;
              var next = parseArguments(readArray, argumentIndex + 1);
              macro $readArray(function(elementStream):Void new com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderPluginStream<$complexRequestType>(elementStream).pluginBuild(function($requestName:$complexRequestType):Void $next));
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
              parameters.push(macro responseHandler);
              macro
              {
                $declareResponseHandler;
                this.service.$methodName($a{parameters});
              }
            }
          }
          var parseAllArguments =
            withDefaultTypeParameters(
              parseArguments(macro readRequest, 0),
              field.params);
          cases.push(
            {
              values: [ macro $v{methodName} ],
              expr: macro switch($parameters)
              {
                case com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream.ARRAY(readRequest):
                {
                  $parseAllArguments;
                }
                case _:
                {
                  throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.UNMATCHED_JSON_TYPE(request, [ "ARRAY" ]);
                }
              }
            });
        }
        case _: throw "Expect method!";
      }
    }
    return
    {
      expr: ESwitch(rpcMethodName, cases, null),
      pos: Context.currentPos(),
    };
  }

  private static function buildSwitchExpr(
    rpcMethodName: ExprOf<String>,
    parameters:ExprOf<AsynchronousJsonStream>):Expr
  {
    for (pair in Context.getLocalClass().get().interfaces)
    {
      switch (pair)
      {
        case
        {
          t: _.get() =>
          {
            module: "com.qifun.jsonStream.rpc.IIncomingProxy",
            name: "IIncomingProxy",
          },
          params: [ TInst(_.get() => serviceClassType, serviceParameters) ]
        }:
          return buildSwitchExprForService(
            serviceClassType,
            serviceParameters,
            rpcMethodName,
            parameters);
        case _:
      }
    }
    return throw "Cannot find IIncomingProxy!";
  }

  #end

  macro public static function build():Array<Field> return
  {
    var switchRpcMethodName = buildSwitchExpr(macro rpcMethodName, macro parameters);
    //trace(ExprTools.toString(switchRpcMethodName));
    var fields = Context.getBuildFields();
    fields.push(
      {
        name: "incomingRpc",
        pos: Context.currentPos(),
        access: [ APublic ],
        kind: FFun(
          {
            args:
            [
              {
                name: "request",
                type: TPath(
                  {
                    pack: [ "com", "qifun", "jsonStream" ],
                    name: "JsonBuilder",
                    sub: "AsynchronousJsonStream",
                  })
              },
              {
                name: "handler",
                type: TFunction(
                  [
                    TPath(
                    {
                      pack: [ "com", "qifun", "jsonStream" ],
                      name: "JsonStream",
                    })
                  ],
                  TPath(
                  {
                    pack: [],
                    name: "Void",
                  }))
              }
            ],
            ret: TPath(
              {
                pack: [],
                name: "Void",
              }),
            expr: macro
            {
              switch (request)
              {
                case com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream.OBJECT(pairs):
                {
                  pairs(function(rpcMethodName, parameters):Void
                  {
                    $switchRpcMethodName;
                  });
                }
                case _:
                {
                  com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.UNMATCHED_JSON_TYPE(request, [ "OBJECT" ]);
                }
              }
            }
          }),
      });
    fields;
  }
}
