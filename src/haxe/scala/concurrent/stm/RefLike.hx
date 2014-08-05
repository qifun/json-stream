package scala.concurrent.stm;

#if (java && scala_stm)

extern interface RefLike<A, Context> extends scala.concurrent.stm.SourceLike<A, Context>
{
  
}

#end