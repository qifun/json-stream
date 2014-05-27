package com.qifun.jsonStream;

import haxe.ds.StringMap.StringMap;

@:final abstract UnknownFieldMap(StringMap<RawJson>)
{
  @:extern
  public inline function new()
  {
    this = new StringMap<RawJson>();
  }
  
  @:extern
  public inline function set(key:String, value:RawJson) return
  {
    this.set(key, value);
  }
  
  @:extern
  public inline function get(key:String) return
  {
    this.get(key);
  }
}
