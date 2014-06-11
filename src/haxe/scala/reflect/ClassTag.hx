package scala.reflect;
import haxe.Int64;

extern interface ClassTag<T> extends OptManifest<T>
{
}


@:native("scala.reflect.ClassTag$")
extern class ClassTagSingleton
{
	@:extern
	public static inline function getInstance():ClassTagSingleton
	{
		return untyped __java__("scala.reflect.ClassTag$.MODULE$");
	}

  public function AnyRef():ClassTag<Dynamic>;
  public function Int():ClassTag<Int>;
  public function Long():ClassTag<Int64>;
  public function Boolean():ClassTag<Bool>;
  public function Float():ClassTag<Single>;
  public function Double():ClassTag<Float>;

}
