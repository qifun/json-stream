package com.qifun.jsonStream;

/**
  表示弱类型的JSON对象。
  
  RawJson实例可以是`null`、`Bool`、`String`、`Float`、`Array`或无类型的结构化对象。
**/
@:final
abstract RawJson(Dynamic)
{
  
  public inline function new(underlying:Dynamic)
  {
    this = underlying;
  }
  
  public var underlying(get, never):Dynamic;
  
  @:extern
  inline function get_underlying():Dynamic return this;

}
