package com.qifun.jsonStream;

import com.qifun.jsonStream.IJsonBuilder;

@:final
private class ObjectBuilder implements IJsonObjectBuilder
{
 
  var object:Dynamic;
  
  public function new(object:Dynamic)
  {
    this.object = object;
  }
  
  public function addPair(key:String):GenericRawJsonBuilder<FieldReference> return
  {
    var result = new GenericRawJsonBuilder<FieldReference>();
    result.object = object;
    result.fieldName = key;
    result;
  }

}

@:final
private class ArrayBuilder implements IJsonArrayBuilder
{
  var array:Array<Dynamic>;
  
  public function new(array:Array<Dynamic>)
  {
    this.array = array;
  }
  
  public function addElement():GenericRawJsonBuilder<ArrayElementReference> return
  {
    var result = new GenericRawJsonBuilder<ArrayElementReference>();
    result.array = array;
    result.index = array.length;
    result;
  }
}

private class FieldReference
{
  public var object:Dynamic;
  
  public var fieldName:String;
  
  public var value(get, set):Dynamic;
  
  private function set_value(value:Dynamic):Dynamic return
  {
    Reflect.setField(object, fieldName, value);
    value;
  }
  
  private function get_value():Dynamic return
  {
    Reflect.field(object, fieldName);
  }
  
  public function new() {}
}

private class ArrayElementReference
{
  
  public var array:Array<Dynamic>;
  
  public var index:Int;
  
  public var value(get, set):Dynamic;
  
  private function set_value(value:Dynamic):Dynamic return
  {
    array[index] = value;
  }
  
  private function get_value():Dynamic return
  {
    array[index];
  }

  public function new() {}
}

@:generic
private class GenericRawJsonBuilder<Reference:
{
  public function new():Void;
  public var value(get, set):Dynamic;
}> extends Reference implements IJsonBuilder
{
  
  public var numberValue(never, set):Float;
  private function set_numberValue(value:Float):Float return
  {
    this.value = value;
  }

  public var stringValue(never, set):String;
  private function set_stringValue(value:String):String return
  {
    this.value = value;
  }

  public function setTrue():Void
  {
    this.value = true;
  }
  
  public function setFalse():Void
  {
    this.value = false;
  }
  
  public function setNull():Void
  {
    this.value = null;
  }
  
  public function beginObject():ObjectBuilder return
  {
    var value = {};
    this.value = value;
    new ObjectBuilder(value);
  }
  
  public function beginArray():ArrayBuilder return
  {
    var value = [];
    this.value = value;
    new ArrayBuilder(value);
  }

}

@:final
class RawJsonBuilder extends GenericRawJsonBuilder<RootReference> implements IRootJsonBuilder<RawJson> {}

private class RootReference
{

  private var _value:Dynamic;
  
  private function set_value(value:Dynamic):Dynamic return
  {
    _value = value;
  }
  
  private function get_value():Dynamic return
  {
    _value;
  }
  
  public function new() { }
  
  public function build() return
  {
    _value;
  }

  public var value(get, set):Dynamic;

}