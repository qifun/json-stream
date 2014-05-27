package com.qifun.jsonStream.unknownValue;

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
  //
  //@:extern
  //public inline function new()
  //{
    //this = new StringMap<RawJson>();
  //}
  //
  //@:extern
  //public inline function set(key:String, value:RawJson) return
  //{
    //this.set(key, value);
  //}
  //
  //@:extern
  //public inline function get(key:String) return
  //{
    //this.get(key);
  //}
}
