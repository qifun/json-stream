package com.qifun.jsonStream;
import haxe.Int64;

@:final class JsonStreamPair
{
  public var key(default, null):String;
  public var value(default, null):JsonStream;
  public function new(key:String, value:JsonStream)
  {
    this.key = key;
    this.value = value;
  }
}

/**
  结构化的JSON数据流。
  
  既可能用于序列化，也可能用于反序列化。
**/
enum JsonStream
{
  //safe type
  NUMBER(value:Float);
  STRING(value:String);
  TRUE;
  FALSE;
  NULL;
  OBJECT(pairs:Iterator<JsonStreamPair>);
  ARRAY(elements:Iterator<JsonStream>);
  //unsafe type
  INT32(value:Int);
  INT64(high:Int, low:Int);
}

