package scala.concurrent.stm;

#if (java && scala_stm)

@:native("scala.concurrent.stm.TMap$View")
extern interface TMapView<A, B> extends
scala.collection.mutable.Map<A, B>
{
  public function tmap():scala.concurrent.stm.TMap<A, B> ;
  
  public function newBuilder():scala.collection.mutable.Builder<scala.Tuple2<A, B>, scala.concurrent.stm.TMapView<A, B>>;
}
#end