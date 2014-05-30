package com.qifun.jsonStream;

typedef JsonPairHandler = Null<String>->Null<AsyncJsonStream>->Void;

typedef JsonElementHandler = Null<AsyncJsonStream>->Void;

typedef AsyncReadJsonArray = JsonElementHandler->Void;

typedef AsyncReadJsonObject = JsonPairHandler->Void;

enum AsyncJsonStream =
{
  TRUE;
  FALSE;
  NULL;
  STRING(value:String);
  NUMBER(value:Float);
  OBJECT(read:AsyncReadJsonObject);
  ARRAY(read:AsyncReadJsonArray);
}

typedef JsonBuilder<T> = AsyncJsonStream->(T->Void)->Void;

/**

**/
interface IJsonBuilder
{

  var numberValue(never, set):Float;
  private function set_numberValue(value:Float):Float;

  var stringValue(never, set):String;
  private function set_stringValue(value:String):String;

  function setTrue():Void;
  function setFalse():Void;
  
  function setNull():Void;
  
  function beginObject():IJsonObjectBuilder;
  
  function beginArray():IJsonArrayBuilder;
  
}

interface IRootJsonBuilder<Result> extends IJsonBuilder
{

  function build():Result;

}

interface IJsonObjectBuilder
{
  
  function addPair(key:String):IJsonBuilder;
  
  function end():Void; // 需要end才能创建枚举

}

interface IJsonArrayBuilder
{
  function addElement():IJsonBuilder;
  function end():Void;
}

