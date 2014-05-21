package com.qifun.jsonStream;

/**
 * @author 杨博
 */
abstract TypedJsonStream<Type>(JsonStream)
{

  public inline function new(underlying:JsonStream) 
  {
    this = underlying;
  }
  
  public inline function toUntypedStream():JsonStream return
  {
    this;
  }
  
}
