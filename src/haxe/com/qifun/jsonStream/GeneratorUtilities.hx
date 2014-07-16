package com.qifun.jsonStream;

#if macro

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.TypeTools;

@:dox(hide)
@:allow(com.qifun.jsonStream)
class GeneratorUtilities
{
  private static function hasEmptyConstructor(classType:ClassType):Bool
  {
    var constructor = classType.constructor;
    if (constructor == null)
    {
      var superClass = classType.superClass;
      if (superClass == null)
      {
        return false;
      }
      else
      {
        return hasEmptyConstructor(classType.superClass.t.get());
      }
    }
    else
    {
      return constructor.get().type.match(TFun([], _));
    }
  }

  private static function isAbstract(classType:ClassType):Bool return
  {
    classType.isInterface ||
    !classType.kind.match(KNormal) ||
    hasEmptyConstructor(classType);
  }

  private static var _lowPriorityDynamicType:Type;

  private static var lowPriorityDynamicType(get, never):Type;

  private static function get_lowPriorityDynamicType():Type return
  {
    if (_lowPriorityDynamicType == null)
    {
      _lowPriorityDynamicType =
        Context.getType("com.qifun.jsonStream.LowPriorityDynamic");
    }
    _lowPriorityDynamicType;
  }

  private static var _hasUnknownTypeFieldType:Type;

  private static var hasUnknownTypeFieldType(get, never):Type;

  private static function get_hasUnknownTypeFieldType():Type return
  {
    if (_hasUnknownTypeFieldType == null)
    {
      _hasUnknownTypeFieldType =
        Context.getType("com.qifun.jsonStream.unknown.UnknownType.HasUnknownTypeField");
    }
    _hasUnknownTypeFieldType;
  }

  private static var _hasUnknownTypeSetterType:Type;

  private static var hasUnknownTypeSetterType(get, never):Type;

  private static function get_hasUnknownTypeSetterType():Type return
  {
    if (_hasUnknownTypeSetterType == null)
    {
      _hasUnknownTypeSetterType =
        Context.getType("com.qifun.jsonStream.unknown.UnknownType.HasUnknownTypeSetter");
    }
    _hasUnknownTypeSetterType;
  }

  private static var VOID_COMPLEX_TYPE(default, never) =
    TPath({ name: "Void", pack: []});

  private static var DYNAMIC_COMPLEX_TYPE(default, never) =
    TPath({ name: "Dynamic", pack: []});

  private static function getFullName(module:String, name:String):String return
  {
    var lastDot = module.lastIndexOf(".");
    if (lastDot == -1)
    {
      name;
    }
    else
    {
      '${module.substring(0, lastDot)}.$name';
    }
  }

}
#end
