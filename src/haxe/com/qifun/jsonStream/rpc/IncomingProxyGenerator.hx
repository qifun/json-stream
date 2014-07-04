package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonStream;
import com.dongxiguo.continuation.utils.Generator;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
using Lambda;
#end

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
    parameters:ExprOf<JsonStream>):Expr
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
              macro com.qifun.jsonStream.rpc.IncomingProxyGenerator.IncomingProxyRuntime.optimizedExtract1(
                $readArray,
                  function(elementStream):Void
                  {
                    var $requestName:$complexRequestType = new com.qifun.jsonStream.JsonDeserializer.JsonDeserializerPluginStream<$complexRequestType>(elementStream).pluginDeserialize();
                    $next;
                  });
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
          var parseRequestExpr =
            withDefaultTypeParameters(
              parseRestRequest(macro readRequest, 0),
              field.params);
          cases.push(
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

  private static function build(
    serviceClassType:ClassType,
    serviceParameters):Array<Field> return
  {
    var switchRpcMethodName =
      buildSwitchExprForService(
        serviceClassType,
        serviceParameters,
        macro rpcMethodName,
        macro parameters);
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
                    name: "JsonStream",
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
                case com.qifun.jsonStream.JsonStream.OBJECT(pairs):
                {
                  com.qifun.jsonStream.rpc.IncomingProxyGenerator.IncomingProxyRuntime.optimizedExtract1(pairs, function(pair):Void
                  {
                    var rpcMethodName = pair.key;
                    var parameters = pair.value;
                    $switchRpcMethodName;
                  });
                }
                case _:
                {
                  com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.UNMATCHED_JSON_TYPE(request, [ "OBJECT" ]);
                }
              }
            }
          }),
      });
    fields;
  }


  #end

  macro public static function buildFromSuperClass():Array<Field> return
  {
    switch (Context.getLocalClass().get().superClass.params)
    {
      case [ TInst(_.get() => serviceClassType, serviceParameters) ]:
      {
        build(serviceClassType, serviceParameters);
      }
      case _:
      {
        throw "Expect 1 type parameter!";
      }
    }
  }

  macro public static function buildFromInterface(
    expectedModule:String,
    expectedName:String):Array<Field> return
  {
    for (pair in Context.getLocalClass().get().interfaces)
    {
      switch (pair)
      {
        case
        {
          t: _.get() =>
          {
            module: m,
            name: n,
          },
          params: [ TInst(_.get() => serviceClassType, serviceParameters) ]
        } if (m == expectedModule && n == expectedName):
          return build(serviceClassType, serviceParameters);
        case _:
      }
    }
    throw 'Cannot find $expectedModule.$expectedName!';

  }
}

@:dox(hide)
class IncomingProxyRuntime
{

  @:extern
  @:noUsing
  private static inline function extract1<Element, Result>(iterator:Iterator<Element>, handler:Element->Result):Result return
  {
    if (iterator.hasNext())
    {
      var element = iterator.next();
      if (iterator.hasNext())
      {
        throw JsonDeserializer.JsonDeserializerError.TOO_MANY_FIELDS(iterator, 1);
      }
      else
      {
        handler(element);
      }
    }
    else
    {
      throw JsonDeserializer.JsonDeserializerError.NOT_ENOUGH_FIELDS(iterator, 1, 0);
    }
  }

  @:extern
  @:noUsing
  public static inline function optimizedExtract1<Element, Result>(iterator:Iterator<Element>, handler:Element->Result):Result return
  {
    var generator = Std.instance(iterator, (Generator:Class<Generator<Element>>));
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
