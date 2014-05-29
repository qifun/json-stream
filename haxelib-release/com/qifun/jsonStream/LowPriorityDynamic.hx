package com.qifun.jsonStream;

/**
  由于Haxe对`Dynamic`特殊处理，如果直接匹配`Dynamic`，会匹配到所有类型。
  使用`LowPriorityDynamic`就只能精确匹配`Dynamic`，所以不会匹配到其他类型。
**/
@:dox(hide)
abstract LowPriorityDynamic(Dynamic) to Dynamic {}