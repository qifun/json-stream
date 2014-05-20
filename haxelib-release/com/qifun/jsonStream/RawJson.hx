package com.qifun.jsonStream;

/**
 * @author 杨博
 */
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
