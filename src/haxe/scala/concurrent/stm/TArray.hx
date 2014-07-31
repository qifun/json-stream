package scala.concurrent.stm;

import scala.reflect.ClassTag;

extern interface TArray<A>
{
}

@:native("scala.concurrent.stm.TArray$")
extern class TArraySingleton
{
	@:extern
	public static inline function getInstance():TArraySingleton
	{
		return untyped __java__("scala.concurrent.stm.TArray$.MODULE$");
	}

	public function ofDim<A>(length: Int, arg0: ClassTag<A>):TArray<A>;
}
