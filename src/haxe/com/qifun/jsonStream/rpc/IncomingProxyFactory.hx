package com.qifun.jsonStream.rpc;

import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonStream;

#if macro
import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.macro.Expr;
import haxe.macro.Type;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonSerializer;
#end

class IncomingProxyFactory
{

  #if macro

  static function processName(sb:StringBuf, s:String):Void
  {
    var i = 0;
    while (i != -1)
    {
      var prev = i;
      i = s.indexOf("_", prev);
      if (i != -1)
      {
        sb.addSub(s, prev, i - prev);
        sb.add("__");
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
    sb.add("newProxy_");
    for (p in pack)
    {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
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
    throw "TODO:";
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
