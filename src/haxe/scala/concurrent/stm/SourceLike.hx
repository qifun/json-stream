package scala.concurrent.stm;

#if (java && scala_stm)

extern interface SourceLike<A, Context>
{
  public function apply(_:Context):A;

  public function get(_:Context):A;

  public function getWith<Z>(function1:scala.Function1<A, Z>, _:Context):Z;

  public function relaxedGet(function2:scala.Function2<A, A, Dynamic>, _:Context):A;
}

#end