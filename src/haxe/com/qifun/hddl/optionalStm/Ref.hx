package com.qifun.hddl.optionalStm;
import haxe.Int64;

#if (java && scala_stm)

import scala.reflect.ClassTag.ClassTagSingleton;
import java.StdTypes;

@:multiType(A)
abstract Ref<A>(scala.concurrent.stm.Ref<A>)
{
  public function new(initialValue:A);

  @:extern
  @:to
  static inline function toObjectRef<A:{}>(t:scala.concurrent.stm.Ref<A>, initialValue:A):scala.concurrent.stm.Ref<A>
  {
    var classTag = ClassTagSingleton.getInstance().AnyRef();
    var dynamicRef:scala.concurrent.stm.Ref<Dynamic> = scala.concurrent.stm.Ref.RefSingleton.getInstance().apply((initialValue:Dynamic), classTag);
    return cast dynamicRef;
  }

  @:extern
  @:to
  static inline function toInt64Ref(t:scala.concurrent.stm.Ref<Int64>, initialValue:Int64):scala.concurrent.stm.Ref<Int64>
  {
    return cast scala.concurrent.stm.Ref.RefSingleton.getInstance().apply(initialValue);
  }

  @:extern
  @:to
  static inline function toChar16Ref(t:scala.concurrent.stm.Ref<Char16>, initialValue:Char16):scala.concurrent.stm.Ref<Char16>
  {
    return cast scala.concurrent.stm.Ref.RefSingleton.getInstance().apply(initialValue);
  }

  @:extern
  @:to
  static inline function toInt16Ref(t:scala.concurrent.stm.Ref<Int16>, initialValue:Int16):scala.concurrent.stm.Ref<Int16>
  {
    return cast scala.concurrent.stm.Ref.RefSingleton.getInstance().apply(initialValue);
  }

  @:extern
  @:to
  static inline function toInt8Ref(t:scala.concurrent.stm.Ref<Int8>, initialValue:Int8):scala.concurrent.stm.Ref<Int8>
  {
    return cast scala.concurrent.stm.Ref.RefSingleton.getInstance().apply(initialValue);
  }

  @:extern
  @:to
  static inline function toIntRef(t:scala.concurrent.stm.Ref<Int>, initialValue:Int):scala.concurrent.stm.Ref<Int>
  {
    return cast scala.concurrent.stm.Ref.RefSingleton.getInstance().apply(initialValue);
  }

  @:extern
  @:to
  static inline function toBoolRef(t:scala.concurrent.stm.Ref<Bool>, initialValue:Bool):scala.concurrent.stm.Ref<Bool>
  {
    return cast scala.concurrent.stm.Ref.RefSingleton.getInstance().apply(initialValue);
  }

  @:extern
  @:to
  static inline function toFloatRef(t:scala.concurrent.stm.Ref<Float>, initialValue:Float):scala.concurrent.stm.Ref<Float>
  {
    return cast scala.concurrent.stm.Ref.RefSingleton.getInstance().apply(initialValue);
  }

  @:extern
  @:to
  static inline function toSingleRef(t:scala.concurrent.stm.Ref<Single>, initialValue:Single):scala.concurrent.stm.Ref<Single>
  {
    return cast scala.concurrent.stm.Ref.RefSingleton_Single.getInstance().apply(initialValue);
  }
}

#else

abstract Ref<T>(T)
{
  public inline function new(initialValue:T)
  {
    this = initialValue;
  }
}

#end
