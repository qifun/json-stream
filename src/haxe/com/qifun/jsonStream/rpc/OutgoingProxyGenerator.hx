package com.qifun.jsonStream.rpc;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
using Lambda;
#end

import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonStream;

@:dox(hide)
class OutgoingProxyRuntime
{
  public static function object1(key1:String, value1:JsonStream):JsonStream return
  {
    JsonStream.OBJECT(new Generator(Continuation.cpsFunction(
      function(yield):Void
        yield(new JsonStreamPair(key1, value1)).async())));
  }
}

@:dox(hide)
class OutgoingProxyGenerator
{
  #if macro

  private static function build(
    serviceClassType:ClassType,
    serviceParameters):Array<Field> return
  {
    var fields = Context.getBuildFields();
    for (field in serviceClassType.fields.get())
    {
      switch (field)
      {
        case { kind: FVar(_) | FMethod(MethMacro) }: continue;
        case
        {
          kind: FMethod(methodKind),
          type: TFun(args, _),
          name: fieldName,
        }:
        {
          var methodName = field.name;
          var numRequestArguments = args.length - 1;
          var responseHandlerType = args[numRequestArguments];
          var responseTypes = switch (args[numRequestArguments].t)
          {
            case TFun(responseTypes, _): responseTypes;
            case _: throw "Expect TFun";
          }
          var requestYieldExprs =
          [
            for (i in 0...numRequestArguments)
            {
              var requestType = TypeTools.applyTypeParameters(
                args[i].t,
                serviceClassType.params,
                serviceParameters);
              var complexRequestType = TypeTools.toComplexType(requestType);
              var requestName = "request" + i;
              macro yield(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData<$complexRequestType>($i{requestName}).pluginSerialize()).async();
            }
          ];
          var requestBlock =
          {
            expr: EBlock(requestYieldExprs),
            pos: Context.currentPos(),
          }

          function parseResponses(
            readArray:Expr,
            responseHandler:Expr,
            responseIndex:Int):Expr return
          {
            if (responseIndex < responseTypes.length)
            {
              var reponseType = TypeTools.applyTypeParameters(
                responseTypes[responseIndex].t,
                serviceClassType.params,
                serviceParameters);
              var complexResponseType = TypeTools.toComplexType(reponseType);
              var responseName = "response" + responseIndex;
              var next =
                parseResponses(
                  readArray,
                  responseHandler,
                  responseIndex + 1);
              macro $readArray(function(elementStream):Void new com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderPluginStream<$complexResponseType>(elementStream).pluginBuild(function($responseName:$complexResponseType):Void $next));
            }
            else
            {
              var parameters =
              [
                for (i in 0...responseTypes.length)
                {
                  var responseName = "response" + i;
                  macro $i{responseName};
                }
              ];
              macro $responseHandler($a{parameters});
            }
          }
          var parseResponseExpr =
            parseResponses(
              macro readResponse,
              macro responseHandler,
              0);
          var args:Array<FunctionArg> =
          [
            for (i in 0...numRequestArguments)
            {
              name: "request" + i,
              type: null,
            }
          ];
          args.push(
            {
              name: "responseHandler",
              type: null,
            });
          var methodBody =
            macro this.outgoingRpc(
              com.qifun.jsonStream.rpc.OutgoingProxyGenerator.OutgoingProxyRuntime.object1(
                $v{methodName},
                com.qifun.jsonStream.JsonStream.ARRAY(
                  new com.dongxiguo.continuation.utils.Generator(
                    com.dongxiguo.continuation.Continuation.cpsFunction(
                      function(yield:com.dongxiguo.continuation.utils.Generator.YieldFunction <
                        com.qifun.jsonStream.JsonStream > ):Void
                        $requestBlock)))),
              function(response:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream):Void
              {
                switch (response)
                {
                  case com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream.ARRAY(readResponse):
                  {
                    $parseResponseExpr;
                  }
                  case _:
                  {
                    throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.UNMATCHED_JSON_TYPE(response, [ "ARRAY" ]);
                  }
                }
              });
          //trace(ExprTools.toString(methodBody));
          fields.push(
            {
              name: fieldName,
              pos: Context.currentPos(),
              access: switch(methodKind)
              {
                case MethInline: [ APublic, AInline ];
                case MethNormal: [ APublic ];
                case MethDynamic: [ APublic, ADynamic ];
                case _: throw "Unexpected MethodKind";
              },
              kind: FFun(
                {
                  args: args,// TODO: responseHandler
                  ret: null,
                  expr: methodBody,
                  params:
                  [
                    for (typeParameter in field.params)
                    {
                      name: typeParameter.name,
                      // TODO: constraits
                    }
                  ],
                }),

            });

        }
        case _: throw "Expect method!";
      }
    }
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
    var localClass = Context.getLocalClass().get();
    for (pair in localClass.interfaces)
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
          return build(
            serviceClassType,
            serviceParameters);
        case _:
      }
    }
    throw 'Cannot find $expectedModule.$expectedName!';
  }
}
