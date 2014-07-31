package scala.concurrent.stm;

extern interface TSet<A>
{
}

@:native("scala.concurrent.stm.TSet$")
extern class TSetSingleton
{
	@:extern
	public static inline function getInstance():TSetSingleton
	{
		return untyped __java__("scala.concurrent.stm.TSet$.MODULE$");
	}

	public function empty<A>():TSet<A>;
}
