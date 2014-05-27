package com.qifun.jsonStream.unknownValue;

import com.qifun.jsonStream.RawJson;
/**
  @author 杨博
**/
class UnknownType
{
  
  public var type(default, null):String;
  public var data(default, null):RawJson;

  public function new(type:String, data:RawJson) 
  {
    this.type = type;
    this.data = data;
  }
  
}