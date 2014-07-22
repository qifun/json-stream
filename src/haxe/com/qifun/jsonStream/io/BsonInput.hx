package com.qifun.jsonStream.io;
import haxe.io.Input;


class BsonInput extends Input
{
  public function discard(n:Int):Void { }
  public function index():Int return { 0; }
  public function size():Int return { 0; }
  public function slice(n: Int):BsonInput return { null; }
  public function readNString():String return { ""; }
  public function readCString():String return { ""; }
  public function readable():Int return { 0; }
}