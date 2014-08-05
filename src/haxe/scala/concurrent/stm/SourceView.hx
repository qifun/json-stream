package scala.concurrent.stm;

#if (java && scala_stm)

@:native("scala.concurrent.stm.Source$View")
extern interface SourceView<A>
{
  public function apply():A;
  
  public function get():A;
}
#end