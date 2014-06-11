package scala.concurrent.stm;

import haxe.Int64;
import scala.reflect.OptManifest;

extern interface Ref<A>
{
}

@:native("scala.concurrent.stm.Ref$")
extern class RefSingleton_Single
{

	@:extern
	public static inline function getInstance():RefSingleton_Single
	{
		return untyped __java__("scala.concurrent.stm.Ref$.MODULE$");
	}

  public function apply(initialValue:Single):Ref<Dynamic>;

}

@:native("scala.concurrent.stm.Ref$")
extern class RefSingleton
{

	@:extern
	public static inline function getInstance():RefSingleton
	{
		return untyped __java__("scala.concurrent.stm.Ref$.MODULE$");
	}

  @:overload(function(initialValue:Int):Ref<Dynamic>{})
  @:overload(function(initialValue:Bool):Ref<Dynamic>{})
  @:overload(function(initialValue:Float):Ref<Dynamic>{})
  @:overload(function(initialValue:Int64):Ref<Dynamic>{})
  public function apply<A>(initialValue: A, om: OptManifest<A>): Ref<A>;

}


//
  //public function apply<A>(initialValue: A, om: OptManifest<A>): Ref<A>;
//
  //@:native("apply")
  //public function applyBool(initialValue:Bool):Ref<Bool>;
//
  //@:native("apply")
  //public function applySingle(initialValue:Single):Ref<Single>;
//
  //@:native("apply")
  //public function applyFloat(initialValue:Float):Ref<Float>;
//
  //@:native("apply")
  //public function applyInt(initialValue:Int):Ref<Int>;
//
  //@:native("apply")
  //public function applyInt64(initialValue:Int64):Ref<Int64>;
