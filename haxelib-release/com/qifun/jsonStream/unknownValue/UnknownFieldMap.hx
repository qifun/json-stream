package com.qifun.jsonStream.unknownValue;

import com.qifun.jsonStream.JsonStream;
import haxe.ds.StringMap;

abstract UnknownFieldMap(StringMap<RawJson>)
{
  public inline function new(underlying:StringMap<RawJson>)
  {
    this = underlying;
  }
  
  public var underlying(get, never):StringMap<RawJson>;
  
  @:extern
  private inline function get_underlying():StringMap<RawJson> return this;
  
}
