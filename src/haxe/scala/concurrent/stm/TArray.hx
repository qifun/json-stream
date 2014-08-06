package scala.concurrent.stm;

#if (scala_stm && java)
import scala.reflect.ClassTag;

extern interface TArray<A>
{
  public function single():scala.concurrent.stm.TArrayView<A>;
}

@:native("scala.concurrent.stm.TArray$")
extern class TArraySingleton
{
	@:native("MODULE$") public static var MODULE(default, never):TArraySingleton;

	public function ofDim<A>(length: Int, arg0: ClassTag<A>):TArray<A>;
  
}
#end