package scala.concurrent.stm;

#if (java && scala_stm)

@:native("scala.concurrent.stm.TSet$View")
extern interface TSetView<A> extends
scala.collection.mutable.Set<A>
{
  public function tset():scala.concurrent.stm.TSet<A>;
  
  public function newBuilder():scala.collection.mutable.Builder<A, scala.concurrent.stm.TSetView<A>>;
}
#end