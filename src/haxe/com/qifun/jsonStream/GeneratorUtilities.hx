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

package com.qifun.jsonStream;

#if macro

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.TypeTools;
using Lambda;

@:dox(hide)
@:allow(com.qifun.jsonStream)
class GeneratorUtilities
{
  private static function jsonFieldName(field:ClassField):String return
  {
    switch (field.meta.extract(":jsonFieldName"))
    {
      case []:
      {
        field.name;
      }
      case [ jsonFieldNameEntry ]:
      {
        switch (jsonFieldNameEntry.params)
        {
          case [ { expr:EConst(CString(value))} ]:
          {
            value;
          }
          default:
          {
            Context.error("Expect exactly one string literal parameter for @:jsonFieldName", Context.currentPos());
          }
        }
      }
      default:
      {
        Context.error("Duplicated metadata @:jsonFieldName", Context.currentPos());
      }
    }
  }

  private static function hasConstructor(classType:ClassType):Bool return
  {
    var constructor = classType.constructor;
    if (constructor == null)
    {
      var superClass = classType.superClass;
      if (superClass == null)
      {
        false;
      }
      else
      {
        hasConstructor(classType.superClass.t.get());
      }
    }
    else
    {
      true;
    }
  }

  private static function isAbstract(classType:ClassType):Bool return
  {
    classType.isInterface ||
    !classType.kind.match(KNormal) ||
    !hasConstructor(classType);
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
