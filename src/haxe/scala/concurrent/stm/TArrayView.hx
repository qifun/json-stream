package scala.concurrent.stm;

#if (scala_stm && java)

@:native("scala.concurrent.stm.TArray$View")
extern interface TArrayView<A> extends scala.collection.mutable.IndexedSeq<A>
{
  public function length():Int;

  public function apply(_:Int):A;

  public function tarray():scala.concurrent.stm.TArray<A>;
  
  @:extern
  public function update(i:Int, element:A):Void;
}
#end