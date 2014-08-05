package scala.concurrent.stm;

#if (java && scala_stm)
import haxe.Int64;
import java.StdTypes;
import scala.reflect.OptManifest;

extern interface Ref<A> extends scala.concurrent.stm.RefLike<A, scala.concurrent.stm.InTxn>
{
  public function single():scala.concurrent.stm.RefView<A>;
}


@:native("scala.concurrent.stm.Ref$")
extern class RefSingleton_Single
{
  @:native("MODULE$") public static var MODULE(default, never):RefSingleton_Single;

  public function apply(initialValue:Single):Ref<Dynamic>;

}

@:native("scala.concurrent.stm.Ref$")
extern class RefSingleton
{

  @:native("MODULE$") public static var MODULE(default, never):RefSingleton;

  @:overload(function(initialValue:Int):Ref<Dynamic>{})
  @:overload(function(initialValue:Bool):Ref<Dynamic>{})
  @:overload(function(initialValue:Float):Ref<Dynamic>{})
  @:overload(function(initialValue:Int64):Ref<Dynamic>{})
  @:overload(function(initialValue:Int8):Ref<Dynamic>{})
  @:overload(function(initialValue:Int16):Ref<Dynamic>{})
  @:overload(function(initialValue:Char16):Ref<Dynamic>{})
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
#end
