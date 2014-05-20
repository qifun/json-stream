package com.qifun.jsonStream;

/**
 * @author 杨博
 */
abstract TypedJsonStream<Type>(JsonStream) to JsonStream
{

  public inline function new(underlying:JsonStream) 
  {
    this = underlying;
  }
  
}
