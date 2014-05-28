package com.qifun.jsonStream.unknownValue;

import com.qifun.jsonStream.JsonStream;
import haxe.ds.StringMap;

@:final abstract UnknownFieldMap(StringMap<RawJson>)
{
  public inline function new(underlying:StringMap<RawJson>)
  {
    this = underlying;
  }
  
  public var underlying(get, never):StringMap<RawJson>;
  
  @:extern
  inline function get_underlying():StringMap<RawJson> return this;
  
}
