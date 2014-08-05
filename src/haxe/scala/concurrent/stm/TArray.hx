package scala.concurrent.stm;

import scala.reflect.ClassTag;

extern interface TArray<A>
{
}

@:native("scala.concurrent.stm.TArray$")
extern class TArraySingleton
{
	@:native("MODULE$") public static var MODULE(default, never):TArraySingleton;

	public function ofDim<A>(length: Int, arg0: ClassTag<A>):TArray<A>;
}
