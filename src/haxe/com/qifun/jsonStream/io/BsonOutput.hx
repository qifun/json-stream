package com.qifun.jsonStream.io;
import haxe.io.Output;

class BsonOutput extends Output
{
  public function index():Int return { 0; }
  public function setInt(index:Int, value:Int):Void { }
  public function writeCString(str:String):Void { }
}