package com.qifun.jsonStream;

@:final class Pair
{
  public var key(default, null):String;
  public var value(default, null):JsonStream;
  public function new(key:String, value:JsonStream)
  {
    this.key = key;
    this.value = value;
  }
}

enum JsonStream
{
  NUMBER(value:Float);
  STRING(value:String);
  TRUE;
  FALSE;
  NULL;
  OBJECT(pairs:Iterator<Pair>);
  ARRAY(elements:Iterator<JsonStream>);
}
