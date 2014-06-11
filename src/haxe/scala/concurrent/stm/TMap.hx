package scala.concurrent.stm;

extern interface TMap<A, B>
{
}

@:native("scala.concurrent.stm.TMap$")
extern class TMapSingleton
{
	@:extern
	public static inline function getInstance():TMapSingleton
	{
		return untyped __java__("scala.concurrent.stm.TMap$.MODULE$");
	}

	public function empty<A, B>():TMap<A, B>;
}
