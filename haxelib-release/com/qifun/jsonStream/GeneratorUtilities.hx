package com.qifun.jsonStream;

import haxe.macro.Expr;

using StringTools;

@:dox(hide)
@:allow(com.qifun.jsonStream)
class GeneratorUtilities
{
  
  private static var VOID_COMPLEX_TYPE(default, never) =
    TPath({ name: "Void", pack: []});

  private static var Dynamic_COMPLEX_TYPE(default, never) =
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