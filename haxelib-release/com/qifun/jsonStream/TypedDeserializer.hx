package com.qifun.jsonStream;

import haxe.macro.Printer;
import Type in StdType;
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

using StringTools;

typedef DeserializeFunction = DeserializeFunctionVector->DeserializeFunctionMap->JsonStream->Dynamic;

typedef DeserializeFunctionVector = Vector<DeserializeFunction>; 

typedef DeserializeFunctionMap = StringMap<DeserializeFunction>; 

abstract Reenter(Dynamic) {}

/**
 * @author 杨博
 */
typedef TypedDeserializerSet =
{
  function dynamicDeserialize(typeName:String, stream:JsonStream):Dynamic;
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
      var generator = com.qifun.jsonStream.TypedDeserializer.asGenerator(iterator);
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

  private var fields(default, null):Array<Field> = [];
  
  private var deserializingTypes(default, null) = new StringMap<BaseType>();
  
  public function new() { }

  static var idSeed = 0;
  
  static function freshDeserializerSetName():String return
  {
    var id = idSeed++;
    return "GeneratedTypedDeserializerSet_" + id;
  }
  
  private static var PACKAGE_PREFIX(default, never) = [ "com", "qifun", "jsonStream", "generated" ];
  
  private static function getInternalPackage():Array<String> return
  {
    function getInternalPackageForBaseType(baseType:BaseType):Array<String> return
    {
      PACKAGE_PREFIX.concat(baseType.pack);
    }
    switch (Context.getLocalType())
    {
      case TInst(t, _): getInternalPackageForBaseType(t.get());
      case TAbstract(t, _): getInternalPackageForBaseType(t.get());
      case TEnum(t, _): getInternalPackageForBaseType(t.get());
      case TType(t, _): getInternalPackageForBaseType(t.get());
      case unsupportedType: throw "Expect BaseType, actual " + unsupportedType;
    }
  }

  private static function processName(sb:StringBuf, s:String):Void
  {
    var i = 0;
    while (i != -1)
    {
      var prev = i;
      i = s.indexOf("_", prev);
      if (i != -1)
      {
        sb.addSub(s, prev, i - prev);
        sb.add("__");
      }
      else
      {
        sb.addSub(s, prev);
        break;
      }
    }
  }

  public static function deserializeMethodName(pack:Array<String>, name:String):String
  {
    var sb = new StringBuf();
    sb.add("deserialize_");
    for (p in pack)
    {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }

  public function defineDeserializerSet():Expr return
  {
    var internalPackage = getInternalPackage();
    var deserializerSetName = freshDeserializerSetName();
    var meta =
    [
      for (deserializingType in deserializingTypes)
      {
        name: ":access",
        params: [ MacroStringTools.toFieldExpr(deserializingType.module.split(".")) ],
        pos : Context.currentPos(),
      }
    ];
    fields.push(
      {
        name: "dynamicDeserialize",
        pos: Context.currentPos(),
        access: [ APublic, AStatic ],
        kind: FFun(extractFunction(macro function(typeName:String, stream:JsonStream):Dynamic return
        {
          // TODO:
          //$dynamicDeserialize
        })),
      });
    var typeDefinition =
    {
      pack: internalPackage,
      name: deserializerSetName,
      pos: Context.currentPos(),
      kind: TDClass(),
      fields: fields,
      meta: meta,
    }
    
    trace(new Printer().printTypeDefinition(typeDefinition));
    fields = null;
    Context.defineType(typeDefinition);
    var internalPackageExpr = MacroStringTools.toFieldExpr(internalPackage);
    macro $internalPackageExpr.$deserializerSetName;
  }

  private static function extractFunction(e:ExprOf<JsonStream->Dynamic>):Function return
  {
    switch (e)
    {
      case { expr: EFunction(null, f) }: f;
      case _: throw "Expect Function";
    }
  }
    
  public function tryAddDeserializeMethod(type:Type):Null<BaseType> return
  {
    function getOrAddDeserializeFunction(type:Type):ExprOf<JsonStream->Dynamic> return
    {
      var typedJsonStream =
        {
          pos: Context.currentPos(),
          expr:
            ENew(
              {
                pack: [ "com", "qifun", "jsonStream" ],
                name: "TypedJsonStream",
                params: [ TPType(TypeTools.toComplexType(type)) ],
              },
              [ macro jsonStream ]),
        }
      var deserializeFunction = macro function(jsonStream:com.qifun.jsonStream.JsonStream) return $typedJsonStream.deserialize();
      var typedExpr = Context.typeExpr(deserializeFunction);
      switch (typedExpr.t)
      {
        case TFun(_, TAbstract(_.get() => { module: "com.qifun.jsonStream.TypedDeserializer", name: "Reenter" }, [])):
          var bt = tryAddDeserializeMethod(type);
          var methodName = deserializeMethodName(bt.pack, bt.name);
          macro $i{methodName}
        case _:
          Context.getTypedExpr(typedExpr);
      }
    }

    function newEnumDeserializeFunction(enumType:EnumType):Function return
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
                var transformed =
                [
                  for (i in 0...args.length)
                  {
                    var parameterName = 'parameter$i';
                    var f = getOrAddDeserializeFunction(args[i].t);
                    macro $f($i{parameterName});
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
      extractFunction(
        macro function (stream:com.qifun.jsonStream.JsonStream) return
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
        });
    }

    function newClassDeserializeFunction(classType:ClassType):Function return
    {
      var cases =
      [
        for (field in classType.fields.get())
        {
          if (field.kind.match(FVar(AccNormal | AccNo, AccNormal | AccNo)))
          {
            var fieldName = field.name;
            var f = getOrAddDeserializeFunction(field.type);
            {
              values: [ macro $v{fieldName} ],
              guard: null,
              expr: macro result.$fieldName = $f(pair.value),
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
      extractFunction(
        macro function (stream:com.qifun.jsonStream.JsonStream) return
        {
          switch (stream)
          {
            case OBJECT(pairs):
              var result = $newInstance;
              var generator = com.qifun.jsonStream.TypedDeserializer.asGenerator(pairs);
              if (generator != null)
              {
                for (pair in generator)
                {
                  $switchKey;
                }
              }
              else
              {
                for (pair in pairs)
                {
                  $switchKey;
                }
              }
              result;
            case _:
              throw "Expect object!";
          }
        });
    }
    
    switch (type)
    {
      case TInst(_.get() => classType, params):
        var methodName = deserializeMethodName(classType.pack, classType.name);
        if (deserializingTypes.get(methodName) == null)
        {
          deserializingTypes.set(methodName, classType);
          fields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              access: [ APublic, AStatic ],
              kind: FFun(newClassDeserializeFunction(classType)),
            });
        }
        classType;
      case TEnum(_.get() => enumType, params):
        var methodName = deserializeMethodName(enumType.pack, enumType.name);
        if (deserializingTypes.get(methodName) == null)
        {
          deserializingTypes.set(methodName, enumType);
          fields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              access: [ APublic, AStatic ],
              kind: FFun(newEnumDeserializeFunction(enumType)),
            });
        }
        enumType;
      case unsupported:
        null;
    }
  }
}

#end


@:final
class TypedDeserializer
{
  
  @:extern
  @:allow(com.qifun.jsonStream.generated)
  private static inline function asGenerator<Element>(iterator:Iterator<Element>):Null<Generator<Element>> return
  {
    Std.instance(iterator, (Generator:Class<Generator<Element>>));
  }
  
  #if macro

    private static var reenter = false;
  
  #end

  /**
   * The fallback deserializeFunction for classes and enums.
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
      var rootExpr = switch (Context.follow(Context.typeof(stream)))
      {
        case TAbstract(_.get() => { module: "com.qifun.jsonStream.TypedJsonStream", name: "TypedJsonStream" }, [ resultType ]):
        {
          var deserializerSetBuilder = new TypedDeserializerSetBuilder();
          trace(resultType);
          var bt = deserializerSetBuilder.tryAddDeserializeMethod(resultType);
          var methodName = TypedDeserializerSetBuilder.deserializeMethodName(bt.pack, bt.name);
          var deserializerSet = deserializerSetBuilder.defineDeserializerSet();
          macro $deserializerSet.$methodName($stream.toUntypedStream());
        }
        case _:
          throw "Expect abstract!";
      }
      reenter = false;
      rootExpr;
    }
  }
  
  @:noUsing
  macro public static function newDeserializerSet(modules:Array<String>):ExprOf<TypedDeserializerSet> return
  {
    if (reenter)
    {
      throw "TypedDeserializer.newDeserializerSet should not be nested in another TypedDeserializer.newDeserializerSet or a TypedDeserializer.deserialize.";
    }
    else
    {
      reenter = true;
      var deserializerSetBuilder = new TypedDeserializerSetBuilder();
      for (moduleName in modules)
      {
        for (rootType in Context.getModule(moduleName))
        {
          deserializerSetBuilder.tryAddDeserializeMethod(rootType);
        }
      }
      var result = deserializerSetBuilder.defineDeserializerSet();
      reenter = false;
      result;
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
    switch (stream.toUntypedStream())
    {
      case ARRAY(elements):
        optimizedJsonArrayStreamToInt64(elements);
      case _:
        throw "Expect number";
    }
  }
}

@:final
class IntDeserializer
{
  // inline // Haxe compiler warns for Java or C# targets if I add the inline modifier
  public static function deserialize(stream:TypedJsonStream<Int>):Int return
  {
    switch (stream.toUntypedStream())
    {
      case NUMBER(value):
        cast value;
      case _:
        throw "Expect number";
    }
  }
}

@:final
class UIntDeserializer
{
  public static function deserialize(stream:TypedJsonStream<UInt>):UInt return
  {
    switch (stream.toUntypedStream())
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
  class SingleDeserializer
  {
    public static function deserialize(stream:TypedJsonStream<Single>):Single return
    {
      switch (stream.toUntypedStream())
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
class FloatDeserializer
{
  public static function deserialize(stream:TypedJsonStream<Float>):Float return
  {
    switch (stream.toUntypedStream())
    {
      case NUMBER(value):
        value;
      case _:
        throw "Expect number";
    }
  }
}

@:final
class BoolDeserializer
{
  public static function deserialize(stream:TypedJsonStream<Bool>):Bool return
  {
    switch (stream.toUntypedStream())
    {
      case FALSE: false;
      case TRUE: true;
      case _: throw "Expect false | true";
    }
  }
}

@:final
class StringDeserializer
{
  public static function deserialize(stream:TypedJsonStream<String>):String return
  {
    switch (stream.toUntypedStream())
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
    switch (stream.toUntypedStream())
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

abstract LowPriorityDynamic(Dynamic) from Dynamic to Dynamic {}

@:final
class LowPriorityDynamicDeserializer
{
  // 由于Haxe对Dynamic特殊处理，如果直接匹配Dynamic，会匹配到其他所有类型
  // 使用LowPriorityDynamic就只能精确匹配Dynamic，所以优先级低于其他能够明确匹配的Deserializer
  public static function deserialize(stream:TypedJsonStream<LowPriorityDynamic>):LowPriorityDynamic
  {
    throw "Cannot deserialize Dynamic type without a TypedDeserializerSet";
  }
}

// TODO: 支持 typedef 和 abstract