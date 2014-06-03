package com.qifun.jsonStream;

abstract JsonObjectBuilder(Null<String>->Null<AsynchronousJsonStream>->Void) from (Null<String>->Null<AsynchronousJsonStream>->Void)
{
  
  public inline function end():Void
  {
    this(null, null);
  }
  
  public inline function addTrue(key:String):Void
  {
    this(key, TRUE);
  }

  public inline function addFalse(key:String):Void
  {
    this(key, FALSE);
  }

  public inline function addNull(key:String):Void
  {
    this(key, NULL);
  }

  public inline function addNumber(key:String, value:Float):Void
  {
    this(key, NUMBER(value));
  }
  
  public inline function addString(key:String, value:String):Void
  {
    this(key, STRING(value));
  }
  
  public inline function addObject(key:String):JsonObjectBuilder return
  {
    var result:Null<JsonObjectBuilder> = null;
    this(key, OBJECT(function(job) return result = job));
    result;
  }
  
  public inline function addArray(key:String):JsonArrayBuilder return
  {
    var result:Null<JsonArrayBuilder> = null;
    this(key, ARRAY(function(jab) return result = jab));
    result;
  }

}

abstract JsonArrayBuilder(Null<AsynchronousJsonStream>->Void) from (Null<AsynchronousJsonStream>->Void)
{
  public inline function end():Void
  {
    this(null);
  }

  public inline function addTrue():Void
  {
    this(TRUE);
  }

  public inline function addFalse():Void
  {
    this(FALSE);
  }

  public inline function addNull():Void
  {
    this(NULL);
  }

  public inline function addNumber(value:Float):Void
  {
    this(NUMBER(value));
  }
  
  public inline function addString(value:String):Void
  {
    this(STRING(value));
  }
  
  public inline function addObject():JsonObjectBuilder return
  {
    var result:Null<JsonObjectBuilder> = null;
    this(OBJECT(function(job) return result = job));
    result;
  }
  
  public inline function addArray():JsonArrayBuilder return
  {
    var result:Null<JsonArrayBuilder> = null;
    this(ARRAY(function(jab) return result = jab));
    result;
  }

}

class JsonBuilder<Result>
{
  
  var asynchronousFunction:AsynchronousJsonStream->(Result->Void)->Void;
  
  public var result(default, null):Result;
  
  public inline function new(asynchronousFunction:AsynchronousJsonStream->(Result->Void)->Void)
  {
    this.asynchronousFunction = asynchronousFunction;
  }
  
  private function newSetter() return function(r):Void
  {
    result = r;
  }
  
  public inline function setTrue():Void
  {
    asynchronousFunction(TRUE, newSetter());
  }
  
  public inline function setFalse():Void
  {
    asynchronousFunction(FALSE, newSetter());
  }
  
  public inline function setNull():Void
  {
    asynchronousFunction(NULL, newSetter());
  }
  
  public var numberValue(never, set):Float;
  
  inline function set_numberValue(value:Float):Float return
  {
    asynchronousFunction(NUMBER(value), newSetter());
    value;
  }
  
  public var stringValue(never, set):String;
  
  inline function set_stringValue(value:String):String return
  {
    asynchronousFunction(STRING(value), newSetter());
    value;
  }
  
  public inline function setObject():JsonObjectBuilder return
  {
    var b:JsonObjectBuilder;
    asynchronousFunction(
      OBJECT(
        function(builder):Void
        {
          b = builder;
        }),
      newSetter());
    b;
  }
  
  public inline function setArray():JsonArrayBuilder return
  {
    var b:JsonArrayBuilder;
    asynchronousFunction(
      ARRAY(
        function(builder):Void
        {
          b = builder;
        }),
      newSetter());
    b;
  }
  
}

@:dox(hide)
enum AsynchronousJsonStream
{
  TRUE;
  FALSE;
  NULL;
  STRING(value:String);
  NUMBER(value:Float);
  OBJECT(read:(Null<String>->Null<AsynchronousJsonStream>->Void)->Void);
  ARRAY(read:(Null<AsynchronousJsonStream>->Void)->Void);
}
