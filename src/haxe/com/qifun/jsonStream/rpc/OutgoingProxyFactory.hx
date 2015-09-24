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
import com.qifun.jsonStream.rpc.JsonHandler.JsonResponse;

#if macro
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.*;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonSerializer;
#end


@:dox(hide)
class OutgoingProxyRuntime
{

  @:noUsing
  public static function object1(key1:String, value1:JsonStream):JsonStream return
  {
    JsonStream.OBJECT(new Generator(Continuation.cpsFunction(
      function(yield):Void @await yield(new JsonStreamPair(key1, value1)))));
  }
}

class OutgoingProxyFactory
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
    sb.add("outgoingProxy_");
    for (p in pack)
    {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }

  static function proxyClassName(pack:Array<String>, name:String):String
  {
    var sb = new StringBuf();
    sb.add("OutgoingProxy_");
    for (p in pack)
    {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }

  static function outgoingProxyField(accessExpr:Expr, localPrefix:Expr, serviceClassType:ClassType):Field return
  {
    var typeParameters =
    [
      for (p in serviceClassType.params)
      {
        TPType(TPath({ pack: [], name: p.name }));
      }
    ];
    var serviceModule = serviceClassType.module;
    var serviceTypePath =
    {
      pack: serviceClassType.pack,
      name: serviceModule.substring(serviceModule.lastIndexOf(".") + 1),
      sub: serviceClassType.name,
      params: typeParameters,
    }
    var serviceComplexType = TPath(serviceTypePath);
    var typeParameterDeclarations:Array<TypeParamDecl> =
    [
      for (p in serviceClassType.params)
      {
        name: p.name,
        // TODO: Constraits
      }
    ];
    var fieldBody = if (Context.defined("doc_gen"))
    {
      macro return ((throw "For documentation generation only!"):$serviceComplexType);
    }
    else
    {
      var pack = Context.getLocalModule().split(".");
      pack[pack.length - 1] = "outgoingProxies_" + pack[pack.length - 1];

      function proxyMethod(
        field:ClassField,
        methodKind:MethodKind,
        args:Array<{ name : String, opt : Bool, t : Type }>,
        responseType:ResponseType):Field return
      {
        var methodName = field.name;
        var numRequestArguments = args.length;
        var methodParameterDeclarations:Array<TypeParamDecl> =
        [
          for (p in field.params)
          {
            name: p.name,
            // TODO: Constraits
          }
        ];
        var allParameterDeclarations = typeParameterDeclarations.concat(methodParameterDeclarations);
        var requestYieldExprs =
        [
          for (i in 0...numRequestArguments)
          {
            var requestType = args[i].t;
            var complexRequestType = TypeTools.toComplexType(requestType);
            var requestName = "request" + i;
            var serializeExpr =
              JsonSerializerGenerator.resolvedSerialize(
                complexRequestType,
                macro $i{requestName},
                allParameterDeclarations);
            macro @await yield($serializeExpr);
          }
        ];
        var requestBlock =
        {
          expr: EBlock(requestYieldExprs),
          pos: Context.currentPos(),
        }
        var implementationArgs:Array<FunctionArg> =
        [
          for (i in 0...numRequestArguments)
          {
            var arg = args[i];
            {
              name: "request" + i,
              type: TypeTools.toComplexType(arg.t),
            }
          }
        ];
        var methodBody =
          switch (responseType)
          {
            case NONVOID_FUTURE(t):
            {
              var complexResponseType = TypeTools.toComplexType(t);
              var deserializeExpr =
                JsonDeserializerGenerator.resolvedDeserialize(
                  complexResponseType,
                  macro responseStream,
                  allParameterDeclarations);
              macro return new com.qifun.jsonStream.rpc.Future.Future1<$complexResponseType>(
                function(responseHandler:$complexResponseType->Void, catcher:Dynamic->Void):Void
                {
                  this.outgoingRpc.apply(
                    com.qifun.jsonStream.rpc.OutgoingProxyFactory.OutgoingProxyRuntime.object1(
                      $v{methodName},
                      com.qifun.jsonStream.JsonStream.ARRAY(
                        new com.dongxiguo.continuation.utils.Generator(
                          com.dongxiguo.continuation.Continuation.cpsFunction(
                            function(yield:com.dongxiguo.continuation.utils.Generator.YieldFunction<
                              com.qifun.jsonStream.JsonStream>):Void
                              $requestBlock)))),
                    new com.qifun.jsonStream.rpc.JsonHandler(
                      function(response:com.qifun.jsonStream.rpc.JsonHandler.JsonResponse):Void
                      {
                        switch (response)
                        {
                          case FAILURE(errorStream):
                          {
                            $localPrefix.handleError(catcher, errorStream);
                          }
                          case SUCCESS(responseStream):
                          {
                            responseHandler($deserializeExpr);
                          }
                        }
                      }));
                });
            }
            case VOID_FUTURE:
            {
              macro return new com.qifun.jsonStream.rpc.Future.Future0(
                function(responseHandler:Void->Void, catcher:Dynamic->Void):Void
                {
                  this.outgoingRpc.apply(
                    com.qifun.jsonStream.rpc.OutgoingProxyFactory.OutgoingProxyRuntime.object1(
                      $v{methodName},
                      com.qifun.jsonStream.JsonStream.ARRAY(
                        new com.dongxiguo.continuation.utils.Generator(
                          com.dongxiguo.continuation.Continuation.cpsFunction(
                            function(yield:com.dongxiguo.continuation.utils.Generator.YieldFunction<
                              com.qifun.jsonStream.JsonStream>):Void
                              $requestBlock)))),
                    new com.qifun.jsonStream.rpc.JsonHandler(
                      function(response:com.qifun.jsonStream.rpc.JsonHandler.JsonResponse):Void
                      {
                        switch (response)
                        {
                          case FAILURE(errorStream):
                          {
                            $localPrefix.handleError(catcher, errorStream);
                          }
                          case SUCCESS(stream):
                          {
                            switch (stream)
                            {
                              case com.qifun.jsonStream.JsonStream.NULL:
                              {
                                responseHandler();
                              }
                              default:
                              {
                                throw com.qifun.jsonStream.rpc.OutgoingProxyFactory.OutgoingProxyError.UNMATCHED_JSON_TYPE(stream, ["NULL"]);
                              }
                            }
                          }
                        }
                      }));
                });
            }
            case VOID:
            {
              macro this.outgoingRpc.push(
                com.qifun.jsonStream.rpc.OutgoingProxyFactory.OutgoingProxyRuntime.object1(
                  $v{methodName},
                  com.qifun.jsonStream.JsonStream.ARRAY(
                    new com.dongxiguo.continuation.utils.Generator(
                      com.dongxiguo.continuation.Continuation.cpsFunction(
                        function(yield:com.dongxiguo.continuation.utils.Generator.YieldFunction<
                          com.qifun.jsonStream.JsonStream>):Void
                          $requestBlock)))));
            }
          }
        //trace(ExprTools.toString(methodBody));
        {
          name: methodName,
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
              args: implementationArgs,
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
        };
      }


      var fields:Array<Field> = [];
      for (field in serviceClassType.fields.get())
      {
        switch (field)
        {
          case { kind: FVar(_) | FMethod(MethMacro) }: continue;
          case
          {
            kind: FMethod(methodKind),
            type: TFun(args, Context.follow(_) => TAbstract(_.get() => { module: "com.qifun.jsonStream.rpc.Future", name: "Future0"}, [ ])),
            name: fieldName,
          }:
          {
            fields.push(proxyMethod(field, methodKind, args, VOID_FUTURE));
          }
          case
          {
            kind: FMethod(methodKind),
            type: TFun(args, Context.follow(_) => TAbstract(_.get() => { module: "com.qifun.jsonStream.rpc.Future", name: "Future1"}, [ responseType ])),
            name: fieldName,
          }:
          {
            fields.push(proxyMethod(field, methodKind, args, NONVOID_FUTURE(responseType)));
          }
          case
          {
            kind: FMethod(methodKind),
            type: TFun(args, Context.follow(_) => TAbstract(_.get() => { pack: [], name: "Void"}, [ ])),
            name: fieldName,
          }:
          {
            fields.push(proxyMethod(field, methodKind, args, VOID));
          }
          default:
          {
            throw "Expect method!";
          }
        }
      }
      var proxyDefinition =
      {
        pack: pack,
        name: proxyClassName(serviceClassType.pack, serviceClassType.name),
        pos: Context.currentPos(),
        params: typeParameterDeclarations,
        isExtern: false,
        meta: [ { name: ":access", params: [ accessExpr ], pos: Context.currentPos(), } ],
        kind: TDClass(
          {
            pack: [ "com", "qifun", "jsonStream", "rpc" ],
            name: "OutgoingProxy",
          },
          [ serviceTypePath ],
          false),
        fields: fields,
      };
      Context.defineType(proxyDefinition);
      var proxyImplementationPath:TypePath =
      {
        name: proxyDefinition.name,
        pack: proxyDefinition.pack,
        params: typeParameters
      };
      macro return new $proxyImplementationPath(outgoingRpc);
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
              name: "outgoingRpc",
              type: JSON_METHOD_COMPLEX_TYPE,
            }
          ],
          ret: null,
          expr: fieldBody,
        })
    }
  }

  static var JSON_METHOD_COMPLEX_TYPE(default, never) = TPath(
    {
      pack: [ "com", "qifun", "jsonStream", "rpc" ],
      name: "IJsonService",
    });

  static function catcherField():Field return
  {
    name: "handleError",
    access: [ AStatic ],
    pos: Context.currentPos(),
    kind: FFun(
      {
        args:
        [
          {
            type: null,
            name: "catcher",
          },
          {
            type: null,
            name: "errorResponse",
          }
        ],
        ret: null,
        expr: macro
        {
          var error:Dynamic = com.qifun.jsonStream.JsonDeserializer.deserialize(errorResponse);
          catcher(error);
        },
      }),
  }

  #end

  @:noUsing
  macro public static function generateOutgoingProxyFactory(includeModules:Array<String>):Array<Field> return
  {
    var fields = Context.getBuildFields();
    fields.push(catcherField());
    var localClass = Context.getLocalClass().get();
    var packExpr = MacroStringTools.toFieldExpr(localClass.pack);
    var localModuleName = localClass.module.substring(localClass.module.lastIndexOf(".") + 1);
    var moduleExpr = packExpr == null ? macro $i{localModuleName} : macro $packExpr.$localModuleName;
    var localName = localClass.name;
    var localPrefix = macro $moduleExpr.$localName;
    var accessExpr = packExpr == null ? macro $i{localName} : macro $packExpr.$localName;
    for (moduleName in includeModules)
    {
      for (rootType in Context.getModule(moduleName))
      {
        switch (rootType)
        {
          case TInst(_.get() => classType, args) if (classType.isInterface):
          {
            fields.push(outgoingProxyField(accessExpr, localPrefix, classType));
          }
          default:
        }
      }
    }
    fields;
  }

}

enum OutgoingProxyError
{
  UNMATCHED_JSON_TYPE(stream:JsonStream, expected: Array<String>);
}

private enum ResponseType
{
  VOID;
  VOID_FUTURE;
  NONVOID_FUTURE(t:Type);
}