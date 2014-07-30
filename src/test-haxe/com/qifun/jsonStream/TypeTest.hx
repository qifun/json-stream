package com.qifun.jsonStream;

#if java
import scala.collection.Seq;
#end

@:final
class TypeTest
{
  public function new() {}
  public var i:Int;
  public var str:String;
  public var f:Float;
  public var bo:Bool;
  #if java
  public var seq:Seq<Int>;
  #end
}
