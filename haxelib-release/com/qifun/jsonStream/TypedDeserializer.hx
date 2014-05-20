package com.qifun.jsonStream;

import haxe.ds.StringMap;
import haxe.ds.Vector;
import haxe.Int64;
import com.dongxiguo.continuation.utils.Generator;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;

typedef DeserializeFunction = DeserializeFunctionVector->JsonStream->Dynamic;

typedef DeserializeFunctionVector = Vector<DeserializeFunction>; 

abstract Reenter(Dynamic) {}

/**
 * @author 杨博
 */
@:final
class TypedDeserializerDetail
{
  
  public static inline function asGenerator<Element>(iterator:Iterator<Element>):Null<Generator<Element>> return
  {
    Std.instance(iterator, (Generator:Class<Generator<Element>>));
  }

  
}

#if macro

@:final
private class TypedDeserializerSetBuilder
{
  
  private static function optimizedExtract<Element>(iterator:ExprOf<Iterator<Element>>, numParametersExpected:Int, handler:Expr):Expr return
  {
    var extractFromIterator = extract(macro iterator, numParametersExpected, handler);
    var extractFromGenerator = extract(macro generator, numParametersExpected, handler);
    macro
    {
      var iterator = $iterator;
      var generator = com.qifun.jsonStream.TypedDeserializer.TypedDeserializerDetail.asGenerator(iterator);
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
  
  private static function extract<Element>(iterator:ExprOf<Iterator<Element>>, numParametersExpected:Int, handler:Expr):Expr return
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

  public static function isType(baseType:BaseType, expectedModule:String, expectedName:String):Bool return
  {
    baseType.module == expectedModule && baseType.name == expectedName;
  }
  
  public var idSeed(default, null) = 0;
  
  public var functionArray(default, null):Array<Expr> = [];
  
  public var idsByType(default, null) = new StringMap<Int>();
  
  public function new() { }
  
  public function buildFunctionVector():ExprOf<DeserializeFunctionVector> return
  {
    var length = functionArray.length;
    var i = 0;
    var initializationBlock =
    [
      for (expr in functionArray)
      {
        var assign = macro v[$v{i}] = $expr;
        i++;
        assign;
      }
    ];
    var initialization =
    {
      pos: Context.currentPos(),
      expr: EBlock(initializationBlock),
    }
    
    macro 
    {
      var v = new DeserializeFunctionVector($v{length});
      $initialization;
      v;
    }
  }
  
  public function getDeserializeFunction(deserializeFunctions:ExprOf<DeserializeFunctionVector>, type:Type):ExprOf<DeserializeFunction> return 
  {
    function deserializeForType(type:Type, stream:ExprOf<JsonStream>):Expr return
    {
      function deserializeExpr(expr:ExprOf<JsonStream>) return
      {
        var typedJsonStream =
          {
            pos: stream.pos,
            expr:
              ENew(
                {
                  pack: [ "com", "qifun", "jsonStream" ],
                  name: "TypedJsonStream",
                  params: [ TPType(TypeTools.toComplexType(type)) ],
                },
                [ expr ]),
          }
        macro $typedJsonStream.deserialize();
      };
      switch (Context.typeof(deserializeExpr(macro null)))
      {
        case TAbstract(t, []) if (isType(t.get(), "com.qifun.jsonStream.TypedDeserializer", "Reenter")):
          var deserializeFunction = getDeserializeFunction(deserializeFunctions, type);
          macro $deserializeFunction($deserializeFunctions, $stream);
        case t:
          var b = deserializeExpr(stream);
          macro $b;
      }
    }

    function newEnumDeserializeFunction(enumType:EnumType):Expr return
    {
      var zeroParameterBranch =
      {
        pos: Context.currentPos(),
        expr: ESwitch(
          macro constructorName,
          [
            for (constructor in enumType.constructs) if (constructor.type.match(TEnum(_, _)))
            {
              var constructorName = constructor.name;
              var enumPath = enumType.module.split(".");
              enumPath.push(enumType.name);
              enumPath.push(constructorName);
              {
                values: [ macro $v{constructorName} ],
                expr: MacroStringTools.toFieldExpr(enumPath),
              }
            }
          ],
          macro throw "Unknown enum value" + constructorName + "!"),
      }
      var extractOne = optimizedExtract(macro pairs, 1, macro processObject);
      var cases = [];
      
      for (constructor in enumType.constructs)
      {
        switch (constructor.type)
        {
          case TFun(args, _):
            var constructorName = constructor.name;
            var enumPath = enumType.module.split(".");
            enumPath.push(enumType.name);
            enumPath.push(constructorName);
            cases.push(
              {
                var i = 0;
                var transformed =
                [
                  for (arg in args)
                  {
                    var parameterName = 'parameter$i';
                    i++;
                    deserializeForType(arg.t, macro $i{parameterName});
                  }
                ];
                var declareProcessParameters =
                {
                  pos: Context.currentPos(),
                  expr:
                    EFunction("inline_processParameters",
                      {
                        args:
                        [
                          for (i in 0...args.length)
                          {
                            name: 'parameter$i',
                            type: TPath(
                              {
                                pack: [ "com", "qifun", "jsonStream" ],
                                name: "JsonStream",
                              }),
                          }
                        ],
                        ret: null,
                        expr:
                        {
                          pos: Context.currentPos(),
                          expr: EReturn(
                          {
                            pos: Context.currentPos(),
                            expr: ECall(MacroStringTools.toFieldExpr(enumPath), transformed),
                          }),
                        }
                      }),
                }
                var extractParameters = optimizedExtract(macro parameters, args.length, macro processParameters);
                ({
                  values: [ macro $v{constructorName} ],
                  expr: macro
                  {
                    switch (pair.value)
                    {
                      case com.qifun.jsonStream.JsonStream.ARRAY(parameters):
                        $declareProcessParameters;
                        $extractParameters;
                      case _:
                        throw "Expect array!";
                    }
                  }
                }:Case);
              });
          case _: // 没有参数的枚举值，前面已经处理过了。
        }
      }
      var processObjectBody =
      {
        pos: Context.currentPos(),
        expr: ESwitch(macro pair.key, cases, macro throw "Unknown enum value" + pair.key + "!"),
      }
     
      var nonzeroParameterBranch =
        macro
        {
          inline function processObject(pair) return
          {
            $processObjectBody;
          }
          $extractOne;
        };
      macro function (deserializeFunctions:com.qifun.jsonStream.TypedDeserializer.DeserializeFunctionVector, stream:com.qifun.jsonStream.JsonStream) return
      {
        switch (stream)
        {
          case STRING(constructorName):
            $zeroParameterBranch;
          case OBJECT(pairs):
            $nonzeroParameterBranch;
          case _:
            throw "Expect object or string!";
        }
      }
    }

    function newClassDeserializeFunction(classType:ClassType):Expr return
    {
      var cases =
      [
        for (field in classType.fields.get())
        {
          if (field.isPublic)
          {
            var fieldName = field.name;
            var valueExpr = deserializeForType(field.type, macro pair.value);
            {
              values: [ macro $v{fieldName} ],
              guard: null,
              expr: macro result.$fieldName = $valueExpr,
            }
          }
        }
      ];
      var classModule = classType.module;
      var newInstance =
      {
        pos: Context.currentPos(),
        expr: ENew(
          {
            pack: classType.pack,
            name: classModule.substring(classModule.lastIndexOf(".")),
            sub: classType.name,
          },
          []),
      }
      var switchKey =
      {
        pos: Context.currentPos(),
        expr: ESwitch(macro pair.key, cases, null),
      }
      macro function (deserializeFunctions:com.qifun.jsonStream.TypedDeserializer.DeserializeFunctionVector, stream:com.qifun.jsonStream.JsonStream) return
      {
        switch (stream)
        {
          case OBJECT(pairs):
            var result = $newInstance;
            for (pair in pairs)
            {
              $switchKey;
            }
            result;
          case _:
            throw "Expect object!";
        }
      }
    }
    
    switch (type)
    {
      case TInst(t, params):
        var classType = t.get();
        var sign = classType.module + "." + classType.name;
        var id = idsByType.get(sign);
        if (id == null)
        {
          id = idSeed++;
          idsByType.set(sign, id);
          functionArray[id] = newClassDeserializeFunction(classType);
        }
        macro deserializeFunctions[$v{id}];
      case TEnum(t, params):
        var enumType = t.get();
        var sign = enumType.module + "." + enumType.name;
        var id = idsByType.get(sign);
        if (id == null)
        {
          id = idSeed++;
          idsByType.set(sign, id);
          functionArray[id] = newEnumDeserializeFunction(enumType);
        }
        macro deserializeFunctions[$v{id}];
      case unsupported:
        throw "Unsupported type: " + TypeTools.toString(unsupported);
    }
  }
}

#end

@:final
class TypedDeserializer
{
    
  #if macro
  
  private static function deserializeRoot<Element>(stream:ExprOf<TypedJsonStream<Element>>):ExprOf<Element> return
  {
    var deserializerSetBuilder = new TypedDeserializerSetBuilder();
    
    switch (Context.follow(Context.typeof(stream)))
    {
      case TAbstract(t, [ resultType ]) if (TypedDeserializerSetBuilder.isType(t.get(), "com.qifun.jsonStream.TypedJsonStream", "TypedJsonStream")):
      {
        var deserializeFunction = deserializerSetBuilder.getDeserializeFunction(macro deserializeFunctions, resultType);
        var functionVector = deserializerSetBuilder.buildFunctionVector();
        macro
        {
          var deserializeFunctions: com.qifun.jsonStream.TypedDeserializer.DeserializeFunctionVector = $functionVector;
          $deserializeFunction(deserializeFunctions, $stream);
        }
      }
      case _:
        throw "Expect abstract!";
    }

  }
  
  private static var reenter = false;
  
  #end
  
  
  /**
   * The fallback deserializeFunction for classes and enums
   */
  macro public static function deserialize<Element>(stream:ExprOf<TypedJsonStream<Element>>):ExprOf<Element> return
  {
    if (reenter)
    {
      macro (null:com.qifun.jsonStream.TypedDeserializer.Reenter);
    }
    else
    {
      reenter = true;
      var rootExpr = deserializeRoot(stream);
      reenter = false;
      trace(ExprTools.toString(rootExpr));
      rootExpr;
    }
  }
}

@:final
class Int64Deserializer
{
  
  macro private static function jsonArrayStreamToInt64(streamIterator:ExprOf<Iterator<JsonStream>>):ExprOf<Int64>
  {
    return macro
    {
      if ($streamIterator.hasNext())
      {
        var highStream = $streamIterator.next();
        if ($streamIterator.hasNext())
        {
          var lowStream = $streamIterator.next();
          if ($streamIterator.hasNext())
          {
            (throw "Expect exact two elements in the array for Int64":Int64);
          }
          else
          {
            switch ([ highStream, lowStream ])
            {
              case [ NUMBER(high), NUMBER(low) ]:
                Int64.make(cast high, cast low);
              case _:
                (throw "Expect exact two number in the array for Int64":Int64);
            }
          }
        }
        else
        {
          (throw "Expect exact two elements in the array for Int64":Int64);
        }
      }
      else
      {
        (throw "Expect exact two elements in the array for Int64":Int64);
      }
      
    }
    
  }
  
  @:protected
  private static function optimizedJsonArrayStreamToInt64(streamIterator:Iterator<JsonStream>):Int64
  {
    var generator = Std.instance(streamIterator, (Generator:Class<Generator<JsonStream>>));
    if (generator !=  null)
    {
      return jsonArrayStreamToInt64(generator);
    }
    else
    {
      return jsonArrayStreamToInt64(streamIterator);
    }
  }

  public static function deserialize(stream:TypedJsonStream<Int64>):Int64 return
  {
    switch (stream:JsonStream)
    {
      case ARRAY(elements):
        optimizedJsonArrayStreamToInt64(elements);
      case _:
        throw "Expect number";
    }
  }
}

@:final
extern class IntDeserializer
{
  public static function deserialize(stream:TypedJsonStream<Int>):Int return
  {
    switch (stream:JsonStream)
    {
      case NUMBER(value):
        cast value;
      case _:
        throw "Expect number";
    }
  }
}

@:final
extern class UIntDeserializer
{
  public static inline function deserialize(stream:TypedJsonStream<UInt>):UInt return
  {
    switch (stream:JsonStream)
    {
      case NUMBER(value):
        cast value;
      case _:
        throw "Expect number";
    }
  }
}

#if (java || cs)
  @:final
  extern class SingleDeserializer
  {
    public static inline function deserialize(stream:TypedJsonStream<Single>):Single return
    {
      switch (stream:JsonStream)
      {
        case NUMBER(value):
          value;
        case _:
          throw "Expect number";
      }
    }
  }
#end

@:final
extern class FloatDeserializer
{
  @:extern
  public static inline function deserialize(stream:TypedJsonStream<Float>):Float return
  {
    switch (stream:JsonStream)
    {
      case NUMBER(value):
        value;
      case _:
        throw "Expect number";
    }
  }
}

@:final
extern class BoolDeserializer
{
  public static inline function deserialize(stream:TypedJsonStream<Bool>):Bool return
  {
    switch (stream:JsonStream)
    {
      case FALSE: false;
      case TRUE: true;
      case _: throw "Expect false | true";
    }
  }
}

@:final
extern class StringDeserializer
{
  public static inline function deserialize(stream:TypedJsonStream<String>):String return
  {
    switch (stream:JsonStream)
    {
      case STRING(value):
        value;
      case _:
        throw "Expect string";
    }
  }
}

@:final
class ArrayDeserializer
{
  public static function deserializeForElement<Element>(stream:TypedJsonStream<Array<Element>>, elementDeserializeFunction:TypedJsonStream<Element>->Element):Array<Element> return
  {
    switch (stream:JsonStream)
    {
      case ARRAY(value):
        var generator = Std.instance(value, (Generator:Class<Generator<JsonStream>>));
        if (generator != null)
        {
          [
            for (element in generator)
            {
              elementDeserializeFunction(new TypedJsonStream(element));
            }
          ];
        }
        else
        {
          [
            for (element in value)
            {
              elementDeserializeFunction(new TypedJsonStream(element));
            }
          ];
        }
      case _:
        throw "Expect array";
    }
  }
  
  macro public static function deserialize<Element>(stream:ExprOf<TypedJsonStream<Array<Element>>>):ExprOf<Array<Element>> return
  {
    macro ArrayDeserializer.deserializeForElement($stream, function(substream) return substream.deserialize());
  }
}

