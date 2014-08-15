package com.qifun.jsonStream;

#if java
import scala.collection.immutable.Seq;
import scala.collection.immutable.Set;
import scala.collection.immutable.Map;
#end

@:final
class TypeEntities
{
  public function new() {}
  public var i:Int;
  public var str:String;
  public var f:Float;
  public var bo:Bool;
  #if (java && scala)
  public var seq:Seq<Int>;
  public var set:Set<Int>;
  public var map:Map<Int, Int>;
  #end
}
