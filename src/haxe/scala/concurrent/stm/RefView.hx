package scala.concurrent.stm;

#if (java && scala_stm)

@:native("scala.concurrent.stm.Ref$View")
extern interface RefView<A> extends scala.concurrent.stm.SourceView<A> extends scala.concurrent.stm.SinkView<A>
{
  public function ref():scala.concurrent.stm.Ref<A>;
}
#end