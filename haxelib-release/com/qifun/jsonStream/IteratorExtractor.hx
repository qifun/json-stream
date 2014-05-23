package com.qifun.jsonStream;

import haxe.macro.Expr;

/**
  @author 杨博
**/
class IteratorExtractor
{
  
  public static function extract<Element>(iterator:ExprOf<Iterator<Element>>, numParametersExpected:Int, handler:Expr):Expr return
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
          throw 'Expect $numParametersExpected elements, actual $i elements.';
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
        throw 'Expect $numParametersExpected elements, actual too many elements.';
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

  public static function optimizedExtract<Element>(iterator:ExprOf<Iterator<Element>>, numParametersExpected:Int, handler:Expr):Expr return
  {
    var extractFromIterator = extract(macro iterator, numParametersExpected, handler);
    var extractFromGenerator = extract(macro generator, numParametersExpected, handler);
    macro
    {
      var iterator = $iterator;
      inline function asGenerator<Element>(iterator:Iterator<Element>) return
      {
        Std.instance(iterator, (com.dongxiguo.continuation.utils.Generator:Class<com.dongxiguo.continuation.utils.Generator<Element>>));
      }
      var generator = asGenerator(iterator);
      if (generator != null)
      {
        $extractFromGenerator;
      }
      else
      {
        $extractFromIterator;
      }
    }
  }


  
}