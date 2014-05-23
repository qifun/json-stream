package com.qifun.jsonStream;


import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator.Generator;
import com.dongxiguo.continuation.utils.Generator.YieldFunction;
import haxe.macro.Expr;

enum IteratorExtractorError<Element>
{
  NotEnoughElements(restoredIterator:Iterator<Element>, expected:Int, actual:Int);
  TooManyElements(restoredIterator:Iterator<Element>, expected:Int);
}

/**
  @author 杨博
**/
class IteratorExtractor
{
  public static function restoredIterator<Element>(extracted:Array<Element>, rest:Iterator<Element>) return
  {
    new Generator(Continuation.cpsFunction(function(yield:YieldFunction<Element>):Void
    {
      for (element in extracted) { yield(element).async(); }
      for (element in rest) { yield(element).async(); }
    }));
  }
  
  macro public static function extract<Element>(iterator:ExprOf<Iterator<Element>>, numParametersExpected:Int, handler:Expr):Expr return
  {
    var extracted = [];
    var block =
    [
      for (i in 0...numParametersExpected)
      {
        var varName = 'extract$i';
        var step = macro var $varName = if ($iterator.hasNext())
        {
          $iterator.next();
        }
        else
        {
          throw com.qifun.jsonStream.IteratorExtractor.IteratorExtractorError.NotEnoughElements(
            $a{extracted}.iterator(),
            $v{numParametersExpected},
            $v{i});
        }
        extracted = extracted.copy();
        extracted.push(macro $i{varName});
        step;
      }
    ];
    var result =
    {
      pos: handler.pos,
      expr: ECall(handler,
        [
          for (i in 0...numParametersExpected) 
          {
            var varName = 'extract$i';
            macro $i{varName};
          }
        ]),
    }
    block.push(
      macro if ($iterator.hasNext())
      {
        throw com.qifun.jsonStream.IteratorExtractor.IteratorExtractorError.TooManyElements(
          com.qifun.jsonStream.IteratorExtractor.restoredIterator($a{extracted}, $iterator),
          $v{numParametersExpected});
      }
      else
      {
        $result;
      });
    {
      pos: handler.pos,
      expr: EBlock(block),
    }
  }

  public static inline function optimizedExtract1<Element, Return>(iterator:Iterator<Element>, handler:Element->Return):Return return
  {
    optimizedExtract(iterator, 1, handler);
  }

  public static inline function optimizedExtract2<Element, Return>(iterator:Iterator<Element>, handler:Element->Element->Return):Return return
  {
    optimizedExtract(iterator, 2, handler);
  }

  macro public static function optimizedExtract<Element>(iterator:ExprOf<Iterator<Element>>, numParametersExpected:Int, handler:Expr):Expr return
  {
    macro
    {
      inline function asGenerator<Element>(iterator:Iterator<Element>) return
      {
        Std.instance(iterator, (com.dongxiguo.continuation.utils.Generator:Class<com.dongxiguo.continuation.utils.Generator<Element>>));
      }
      var extractingIterator = $iterator;
      var generator = asGenerator(extractingIterator);
      if (generator != null)
      {
        com.qifun.jsonStream.IteratorExtractor.extract(generator, $v{numParametersExpected}, $handler);
      }
      else
      {
        com.qifun.jsonStream.IteratorExtractor.extract(extractingIterator, $v{numParametersExpected}, $handler);
      }
    }
  }

}
