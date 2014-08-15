package com.qifun.jsonStream;


class StmEntity
{

  public function new() { }
  #if (scala_stm && java)
  public var ref:scala.concurrent.stm.Ref<Int>;
  public var tset:scala.concurrent.stm.TSet<Int>;
  public var tmap:scala.concurrent.stm.TMap<Int, Int>;
  public var tarray:scala.concurrent.stm.TArray<Int>;
  #end
}
