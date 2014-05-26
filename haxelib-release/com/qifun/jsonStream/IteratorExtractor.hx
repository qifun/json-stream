package com.qifun.jsonStream;


import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator.Generator;
import com.dongxiguo.continuation.utils.Generator.YieldFunction;
import haxe.macro.Expr;

@:final class UntranslatableElement<InputElement, TranslatedElement> implements IStreamException<Iterator<InputElement>>
{
  
  private var translatedElements:Array<TranslatedElement>;
  
  private var underlyingException:IStreamException<InputElement>;
  
  public var rebuildInput(default, null):TranslatedElement->InputElement;

  private var rest:Iterator<InputElement>;
  
  public function new(translatedElements:Array<TranslatedElement>, underlyingException:IStreamException<InputElement>, rebuildInput:TranslatedElement->InputElement, rest:Iterator<InputElement>)
  {
    this.translatedElements = translatedElements;
    this.underlyingException = underlyingException;
    this.rebuildInput = rebuildInput;
    this.rest = rest;
  }
  
  public function toString() return
  {
    'Cannot translate the ${translatedElements.length}-th element.';
  }
  
  public function recover():Generator<InputElement> return
  {
    new Generator(Continuation.cpsFunction(function(yield:YieldFunction<InputElement>):Void
    {
      for (translatedElement in translatedElements)
      {
        yield(rebuildInput(translatedElement)).async();
      }
      yield(underlyingException.recover()).async();
      for (e in rest)
      {
        yield(e).async();
      }
    }));
  }
  
}  

@:final
class NotEnoughElements<InputElement, TranslatedElement> implements IStreamException<Iterator<InputElement>>
{
  
  private var translatedElements:Array<TranslatedElement>;
  
  public var expected(default, null):Int;
  
  public var rebuildInput(default, null):TranslatedElement->InputElement;
  
  public function new(translatedElements:Array<TranslatedElement>, rebuildInput:TranslatedElement->InputElement, expected:Int)
  {
    this.translatedElements = translatedElements;
    this.rebuildInput = rebuildInput;
    this.expected = expected;
  }
  
  public function toString() return
  {
    'Expect $expected elements, actual ${translatedElements.length} elements.';
  }
  
  public function recover():Iterator<InputElement> return
  {
    new Generator(Continuation.cpsFunction(function(yield:YieldFunction<InputElement>):Void
    {
      for (translatedElement in translatedElements)
      {
        yield(rebuildInput(translatedElement)).async();
      }
    }));
  }
  
}

@:final
class TooManyElements<InputElement, TranslatedElement> implements IStreamException<Iterator<InputElement>>
{
  
  private var translatedElements:Array<TranslatedElement>;
  
  public var rebuildInput(default, null):TranslatedElement->InputElement;

  private var rest:Iterator<InputElement>;
  
  public function new(translatedElements:Array<TranslatedElement>, rebuildInput:TranslatedElement->InputElement, rest:Iterator<InputElement>)
  {
    this.translatedElements = translatedElements;
    this.rebuildInput = rebuildInput;
    this.rest = rest;
  }
  
  public function toString() return
  {
    'Expect ${translatedElements.length} elements, actual more than ${translatedElements.length} elements.';
  }
  
  public function recover():Generator<InputElement> return
  {
    new Generator(Continuation.cpsFunction(function(yield:YieldFunction<InputElement>):Void
    {
      for (translatedElement in translatedElements)
      {
        yield(rebuildInput(translatedElement)).async();
      }
      for (e in rest)
      {
        yield(e).async();
      }
    }));
  }
  
}


/**
  @author 杨博
**/
class IteratorExtractor
{

  macro public static function extract<InputElement, TranslatedElement>(
    iterator:ExprOf<Iterator<InputElement>>,
    numParametersExpected:Int,
    translate:ExprOf<InputElement->TranslatedElement>,
    rebuildInput:ExprOf<TranslatedElement->InputElement>,
    handler:Expr):Expr return
  {
    var extracted = [];
    var block =
    [
      for (i in 0...numParametersExpected)
      {
        var varName = 'extract$i';
        var step = macro var $varName = if ($iterator.hasNext())
        {
          var input = $iterator.next();
          try
          {
            $translate(input);
          }
          catch (e:com.qifun.jsonStream.IStreamException<Dynamic>)
          {
            throw new com.qifun.jsonStream.IteratorExtractor.UntranslatableElement(
              $a{extracted},
              e,
              $rebuildInput,
              $iterator);
          }
        }
        else
        {
          throw new com.qifun.jsonStream.IteratorExtractor.NotEnoughElements(
            $a{extracted},
            $rebuildInput,
            $v{numParametersExpected});
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
        throw new com.qifun.jsonStream.IteratorExtractor.TooManyElements(
            $a{extracted},
            $rebuildInput,
            $iterator);
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
  

  
  public static inline function identity<A, B>(a:A):A return a;

  public static inline function optimizedExtract1<InputElement, TranslatedElement, Return>(
    iterator:Iterator<InputElement>,
    translate:InputElement->TranslatedElement,
    rebuildInput:TranslatedElement->InputElement,
    handler:TranslatedElement->Return):Return return
  {
    optimizedExtract(iterator, 1, translate, rebuildInput, handler);
  }

  public static inline function optimizedExtract2<InputElement, TranslatedElement, Return>(
    iterator:Iterator<InputElement>,
    ?translate:InputElement->TranslatedElement,
    ?rebuildInput:TranslatedElement->InputElement,
    handler:TranslatedElement->TranslatedElement->Return):Return return
  {
    optimizedExtract(iterator, 2, translate, rebuildInput, handler);
  }

  macro public static function optimizedExtract<InputElement, TranslatedElement>(
    iterator:ExprOf<Iterator<InputElement>>,
    numParametersExpected:Int,
    translate:ExprOf<InputElement->TranslatedElement>,
    rebuildInput:ExprOf<TranslatedElement->InputElement>,
    handler:Expr):Expr return
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
        com.qifun.jsonStream.IteratorExtractor.extract(generator, $v{numParametersExpected}, $translate, $rebuildInput, $handler);
      }
      else
      {
        com.qifun.jsonStream.IteratorExtractor.extract(extractingIterator, $v{numParametersExpected}, $translate, $rebuildInput, $handler);
      }
    }
  }

}
