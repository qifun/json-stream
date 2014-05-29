package com.qifun.jsonStream;

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
  NUMBER(value:Float);
  STRING(value:String);
  TRUE;
  FALSE;
  NULL;
  OBJECT(pairs:Iterator<JsonStreamPair>);
  ARRAY(elements:Iterator<JsonStream>);
}
