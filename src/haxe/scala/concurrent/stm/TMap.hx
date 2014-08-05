package scala.concurrent.stm;

#if (scala_stm && java)

extern interface TMap<A, B>
{
  public function single():scala.concurrent.stm.TMapView<A, B>;
}

@:native("scala.concurrent.stm.TMap$")
extern class TMapSingleton
{
	@:native("MODULE$") public static var MODULE(default, never):TMapSingleton;

  public function newBuilder<A, B>():scala.collection.mutable.Builder<scala.Tuple2<A, B>, scala.concurrent.stm.TMap<A, B>>;
  
	public function empty<A, B>():TMap<A, B>;
}
#end