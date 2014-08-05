package scala.concurrent.stm;

#if (scala_stm && java)
extern interface TSet<A>
{
  public function single():scala.concurrent.stm.TSetView<A>;
}

@:native("scala.concurrent.stm.TSet$")
extern class TSetSingleton
{
	@:native("MODULE$") public static var MODULE(default, never):TSetSingleton;
  
  public function newBuilder<A>():scala.collection.mutable.Builder<A, scala.concurrent.stm.TSet<A>>;


	public function empty<A>():TSet<A>;
}
#end