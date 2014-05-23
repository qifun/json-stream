package com.qifun.jsonStream;


import haxe.macro.Expr;

enum IteratorExtractorError<Element>
{
  NotEnoughElements(iterator:Iterator<Element>, expected:Int, actual:Int);
  TooManyElements(iterator:Iterator<Element>, expected:Int);
}

/**
  @author 杨博
**/
class IteratorExtractor
{
  
  macro public static function extract<Element>(iterator:ExprOf<Iterator<Element>>, numParametersExpected:Int, handler:Expr):Expr return
  {
    var block =
    [
      for (i in 0...numParametersExpected)
      {
        var varName = 'extract$i';
        macro var $varName = if ($iterator.hasNext())
        {
          $iterator.next();
        }
        else
        {
          throw com.qifun.jsonStream.IteratorExtractor.IteratorExtractorError.NotEnoughElements($iterator, $v{numParametersExpected}, $v{i});
        }
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
        throw com.qifun.jsonStream.IteratorExtractor.IteratorExtractorError.TooManyElements($iterator, $v{numParametersExpected});
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
