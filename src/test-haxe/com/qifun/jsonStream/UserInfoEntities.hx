package com.qifun.jsonStream;
import haxe.io.Bytes;

@:final
class UserInfoEntities
{
  public function new() {}
  public var hp:haxe.Int64;
  public var mp:Int;
  public var skills:Array<Int> = [];
  public var md5Code:Bytes;
}