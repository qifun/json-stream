package scala.concurrent.stm;

#if (java && scala_stm)

@:native("scala.concurrent.stm.Sink$View")
extern interface SinkView<A>
{
  public function set(_:A):Void;
  
  public function update(_:A):Void;
  
  public function trySet(_:A):Bool;
}
#end