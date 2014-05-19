package com.qifun.jsonStream;

using Type;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Type;
#end
import haxe.Int64;
using Lambda;
using StringTools;
import com.dongxiguo.continuation.utils.Generator.Generator;
import haxe.ds.StringMap;


@:final
class Typed
{
  
  #if macro
  private static function toStringMap(initializers:Array<Expr>)
  {
    if (initializers.length == 0)
    {
      return macro new haxe.ds.StringMap();
    }
    else
    {
      return macro $a{initializers};
    }
  }
    
  private static inline var PACKAGE_PREFIX = "com.qifun.jsonStream.jsonStreamToTypedInstance.";
  
  private static function createConverterClass(className:String):TypeDefinition
  {
    
    if (!className.startsWith(PACKAGE_PREFIX))
    {
      return null;
    }
    var originalClassName = className.substring(PACKAGE_PREFIX.length);
    trace(originalClassName);
    return null; // TODO
  }
  
  private static var isRegiestered = false;

  private static function regiester():Void
  {
    if (!isRegiestered)
    {
      Context.onTypeNotFound(createConverterClass);
      Context.onAfterGenerate(function() { isRegiestered = false; });
      isRegiestered = true;
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
  
  private static function classVarName(pack:Array<String>, name:String):String
  {
    var sb = new StringBuf();
    sb.add("__classFieldMap_");
    for (p in pack)
    {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }
  
  private static function enumVarName(pack:Array<String>, name:String):String
  {
    var sb = new StringBuf();
    sb.add("__enumConstructorMap_");
    for (p in pack)
    {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }

  #end

  @:noUsing
  macro public static function newDescriptorSet(includeModules: Array<String>):haxe.macro.ExprOf<DescriptorSet>
  {
    // TODO: 为以上文件中的类提供分发服务
    var block = [];
    var fieldDescriptorInitializers = [];
    var enumDescriptorSetInitializers = [];
    var classDescriptorSetInitializers = [];

    function baseTypeDescriptorExpr(baseType:BaseType):ExprOf<TypeDescriptor>
    {
      switch (baseType)
      {
        case { module: "haxe.Int64", name: "Int64" } :
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.INT64;
        case { module: "UInt", name: "UInt" } :
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.UINT;
        case { module: "StdTypes", name: "Bool" } :
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.BOOL;
        case { module: "StdTypes", name: "Float" } :
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.FLOAT;
        case { module: "StdTypes", name: "Int" } :
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.INT;
        case { module: "String", name: "String" } :
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.STRING;
        case { pack: p, name: n } if (!baseType.meta.has(":final")):
          var varName = classVarName(p, n);
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.CLASS($i{varName});
        case _:
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.DYNAMIC;
      }
    }
    
    function classTypeDescriptorExpr(classType:ClassType):ExprOf<TypeDescriptor>
    {
      switch (classType)
      {
        case { module: "String", name: "String" } :
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.STRING;
        case { module: "haxe.Int64", name: "Int64" } :
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.INT64;
        case { pack: p, name: n, isInterface: false } if (!classType.meta.has(":final")):
          var varName = classVarName(p, n);
          var qnames = classType.module.split(".");
          qnames.push(n);
          var classExpr = MacroStringTools.toFieldExpr(qnames);
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.CLASS($classExpr, $i{varName});
        case _:
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.DYNAMIC;
      }
    }
    
    function typeDescriptorExpr(type:Type):ExprOf<TypeDescriptor>
    {
      switch (Context.follow(type, false))
      {
        case TEnum(t, params):
        {
          var enumType = t.get();
          var varName = enumVarName(enumType.pack, enumType.name);
          var qnames = enumType.module.split(".");
          qnames.push(enumType.name);
          var enumExpr = MacroStringTools.toFieldExpr(qnames);
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.ENUM($enumExpr, $i{varName});
        }
        case TInst(t, params):
          return classTypeDescriptorExpr(t.get());
        case TAbstract(t, params):
          switch (t.get())
          {
            case { module: "UInt", name: "UInt" } :
              return macro com.qifun.jsonStream.Typed.TypeDescriptor.UINT;
            case { module: "StdTypes", name: "Bool" } :
              return macro com.qifun.jsonStream.Typed.TypeDescriptor.BOOL;
            case { module: "StdTypes", name: "Single" } :
              // 和Float一样处理，希望编译器能自动隐式转换
              return macro com.qifun.jsonStream.Typed.TypeDescriptor.FLOAT;
            case { module: "StdTypes", name: "Float" } :
              return macro com.qifun.jsonStream.Typed.TypeDescriptor.FLOAT;
            case { module: "StdTypes", name: "Int" } :
              return macro com.qifun.jsonStream.Typed.TypeDescriptor.INT;
            case { module: "haxe.Int64", name: "Int64" } :
              return macro com.qifun.jsonStream.Typed.TypeDescriptor.INT64;
            case { impl: i }:
              return classTypeDescriptorExpr(i.get());
            case _:
              return macro com.qifun.jsonStream.Typed.TypeDescriptor.DYNAMIC;
          }
        case _:
          return macro com.qifun.jsonStream.Typed.TypeDescriptor.DYNAMIC;
      }
    }
    
    for (moduleName in includeModules)
    {
      for (type in Context.getModule(moduleName))
      {
        switch (type)
        {
          case TEnum(t, params):
            var enumType = t.get();
            var qname = MacroStringTools.toDotPath(enumType.pack, enumType.name);
            var varName = enumVarName(enumType.pack, enumType.name);
            enumDescriptorSetInitializers.push(macro $v{qname} => $i{varName});
            block.push(macro var $varName = new haxe.ds.StringMap<Iterable<TypeDescriptor>>());
            for (constructor in enumType.constructs)
            {
              var constructorName = constructor.name;
              var parameterTypeDescriptorExprs =
                switch (constructor.type)
                {
                  case TFun(args, _): 
                    [
                      for (parameter in args)
                      {
                        typeDescriptorExpr(parameter.t);
                      }
                    ];
                  case TEnum(_, _):
                    [];
                  case _:
                    throw "Constructor must be a TFun or TEnum!";
                }
              fieldDescriptorInitializers.push(macro $i{varName}.set($v{constructorName}, $a{parameterTypeDescriptorExprs}));
            }
          case TInst(t, params):
            var instType = t.get();
            if (!instType.isInterface)
            {
              var qname = MacroStringTools.toDotPath(instType.pack, instType.name);
              var varName = classVarName(instType.pack, instType.name);
              classDescriptorSetInitializers.push(macro $v{qname} => $i{varName});
              block.push(macro var $varName = new haxe.ds.StringMap<com.qifun.jsonStream.Typed.TypeDescriptor>());
              for (field in instType.fields.get())
              {
                if (field.isPublic)
                {
                  var fieldName = field.name;
                  var typeDescriptor = typeDescriptorExpr(field.type);
                  fieldDescriptorInitializers.push(macro $i{varName}.set($v{fieldName}, $typeDescriptor));
                }
              }
            }
          case _ :
        }
      }
      
    }
    block.push(
    {
      expr: EBlock(fieldDescriptorInitializers),
      pos: Context.currentPos(),
    });

    var enumDescriptorSet = toStringMap(enumDescriptorSetInitializers);
    var classDescriptorSet = toStringMap(classDescriptorSetInitializers);
    block.push(macro new com.qifun.jsonStream.Typed.DescriptorSet($classDescriptorSet, $enumDescriptorSet));
    trace(ExprTools.toString({ expr: EBlock(block), pos: Context.currentPos(), }));
    return 
    {
      expr: EBlock(block),
      pos: Context.currentPos(),
    };
  }
  
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
    
  macro private static function jsonArrayStreamToEnumConstructorParameters(
    descriptorSet:ExprOf<DescriptorSet>,
    parameterDescriptors:ExprOf<Iterable<TypeDescriptor>>,
    streamIterator:ExprOf<Iterator<JsonStream>>):ExprOf<Array<Dynamic>>
  {
    return macro
    {
      var result =
      [
        for (parameterDescriptor in $parameterDescriptors)
        {
          if ($streamIterator.hasNext())
          {
            var stream = $streamIterator.next();
            toInstance(stream, $descriptorSet, parameterDescriptor);
          }
          else
          {
            throw "Expect more parameter for the enum constructor parameter list";
          }
        }
      ];
      if ($streamIterator.hasNext())
      {
        throw "Expect end of array for the enum constructor parameter list";
      }
      result;
    }
  }
  
  macro private static function jsonObjectStreamToDynamicInstance(descriptorSet: ExprOf<DescriptorSet>, pairs:ExprOf<Iterator<JsonStream.PairStream>>):ExprOf<Dynamic>
  {
    return macro
    {
      if ($pairs.hasNext())
      {
        var pair = $pairs.next();
        if ($pairs.hasNext())
        {
          throw "Expect exact one key/value pair for dynamic field.";
        }
        else
        {
          var key = pair.key;
          return pairStreamToDynamicInstance($descriptorSet, key, pair.value);
        }
      }
      else
      {
        throw "Expect exact one key/value pair for dynamic field.";
      }
    }
  }
  
  macro private static function jsonObjectStreamToClassInstance<C>(descriptorSet:ExprOf<DescriptorSet>, reflectClass:ExprOf<Class<C>>, fieldMap:ExprOf<FieldMap>, pairs:ExprOf<Iterator<JsonStream.PairStream>>):ExprOf<C>
  {
    return macro
    {
      var result = $reflectClass.createInstance([]);
      for (pair in $pairs)
      {
        var fieldName = pair.key;
        var typeDescriptor = $fieldMap.get(fieldName);
        var fieldInstance:Dynamic =
          if (typeDescriptor == null)
          {
            // Unknown field, set untyped json instance.
            Untyped.toInstance(pair.value);
          }
          else
          {
            toInstance(pair.value, $descriptorSet, typeDescriptor);
          }
        Reflect.setField(result, fieldName, fieldInstance);
      }
      result;
    }
  }
  
  macro private static function jsonObjectStreamToEnumInstance<E>(descriptorSet:ExprOf<DescriptorSet>, reflectEnum:ExprOf<Enum<E>>, constructors:ExprOf<EnumConstructorMap>, pairs:ExprOf<Iterator<JsonStream.PairStream>>):ExprOf<E>
  {
    return macro
    {
      if ($pairs.hasNext())
      {
        var pair = $pairs.next();
        if ($pairs.hasNext())
        {
          throw "Expect only one key/value pair for enum!";
        }
        else
        {
          switch (pair.value)
          {
            case ARRAY(parameters):
              var constructorName = pair.key;
              var parameterDescriptors = $constructors.get(constructorName);
              return $reflectEnum.createByName(
                constructorName,
                optimizedJsonArrayStreamToEnumConstructorParameters($descriptorSet, parameterDescriptors, parameters));
            case _:
              throw "Expect an array for enum constructor parameters!";
          }
        }
      }
      else
      {
        throw "Expect exact one key/value pair for enum!";
      }
    }
  }

  #if !macro

  @:protected
  private static function pairStreamToDynamicInstance(descriptorSet:DescriptorSet, key:String, value:JsonStream):Dynamic
  {
    switch (key)
    {
      case "Int", "UInt", "Float", "Single":
        return toFloatInstance(value);
      case "haxe.Int64":
        return toInt64Instance(value);
      case "String":
        return toStringInstance(value);
      case "Bool":
        return toBoolInstance(value);
      case key:
        if (key.startsWith("Array<") && key.endsWith(">"))
        {
          var elementKey = key.substring("Array<".length, key.length - ">".length);
          switch (value)
          {
            case ARRAY(elements):
              var generator = Std.instance(elements, (Generator:Class<Generator<JsonStream>>));
              if (generator != null)
              {
                return
                [
                  for (element in generator)
                  {
                    pairStreamToDynamicInstance(descriptorSet, elementKey, element);
                  }
                ];
              }
              else
              {
                return
                [
                  for (element in elements)
                  {
                    pairStreamToDynamicInstance(descriptorSet, elementKey, element);
                  }
                ];
              }
            case _:
              return throw "Expect array";
          }
        }
        else
        {
          return switch (descriptorSet.fieldMaps.get(key))
          {
            case null:
              switch (descriptorSet.constructorMaps.get(key))
              {
                case null:
                  throw "Unknown type " + key;
                case constructors:
                  toEnumInstance(value, descriptorSet, key.resolveEnum(), constructors);
              }
            case fields:
              toClassInstance(value, descriptorSet, key.resolveClass(), fields);
          }
        }
    }
  }
  
  public static function toEnumInstance<E>(stream:JsonStream, descriptorSet:DescriptorSet, reflectEnum:Enum<E>, constructors:EnumConstructorMap):E
  {
    switch (stream)
    {
      case STRING(constructorName):
        return reflectEnum.createByName(constructorName);
      case OBJECT(pairs):
        var generator = Std.instance(pairs, (Generator:Class<Generator<JsonStream.PairStream>>));
        if (generator != null)
        {
          return jsonObjectStreamToEnumInstance(descriptorSet, reflectEnum, constructors, generator);
        }
        else
        {
          return jsonObjectStreamToEnumInstance(descriptorSet, reflectEnum, constructors, pairs);
        }
      case _:
        throw "Expect string or array for enum!";
    }
  }

  public static function toClassInstance<C>(stream:JsonStream, descriptorSet:DescriptorSet, reflectClass:Class<C>, fieldMap:FieldMap):C
  {
    switch (stream)
    {
      case OBJECT(pairs):
        var generator = Std.instance(pairs, (Generator:Class<Generator<JsonStream.PairStream>>));
        if (generator != null)
        {
          return jsonObjectStreamToClassInstance(descriptorSet, reflectClass, fieldMap, generator);
        }
        else
        {
          return jsonObjectStreamToClassInstance(descriptorSet, reflectClass, fieldMap, pairs);
        }
      case _:
        return throw "Expect object!";
    }
  }
  
  public static function toInt64Instance(stream:JsonStream):Int64
  {
    switch (stream)
    {
      case ARRAY(elements):
        return optimizedJsonArrayStreamToInt64(elements);
      case _:
        return throw "Expect array!";
    }
  }
  
  public static function toStringInstance(stream:JsonStream):String
  {
    switch (stream)
    {
      case STRING(value):
        return value;
      case _:
        return throw "Expect string!";
    }
  }
  
  public static function toBoolInstance(stream:JsonStream):Bool
  {
    switch (stream)
    {
      case FALSE: return false;
      case TRUE: return false;
      case _: return throw "Expect true or false";
    }
  }
  
  public static function toFloatInstance(stream:JsonStream):Float
  {
    switch (stream)
    {
      case NUMBER(value):
        return value;
      case _:
        return throw "Expect number";
    }
  }
  
  public static function toArrayInstance(stream:JsonStream, descriptorSet:DescriptorSet, elementTypeDescriptor:TypeDescriptor):Array<Dynamic>
  {
    switch (stream)
    {
      case ARRAY(elements):
        var generator = Std.instance(elements, (Generator:Class<Generator<JsonStream>>));
        if (generator != null)
        {
          return
          [
            for (element in generator)
            {
              toInstance(element, descriptorSet, elementTypeDescriptor);
            }
          ];
        }
        else
        {
          return
          [
            for (element in elements)
            {
              toInstance(element, descriptorSet, elementTypeDescriptor);
            }
          ];
        }
      case _:
        return throw "Expect array";
    }
  }
  
  public static function toInstance(stream:JsonStream, descriptorSet:DescriptorSet, typeDescriptor:TypeDescriptor):Dynamic
  {
    switch (typeDescriptor)
    {
      case DYNAMIC:
        return toDynamicInstance(stream, descriptorSet);
      case CLASS(reflectClass, fields):
        return toClassInstance(stream, descriptorSet, reflectClass, fields);
      case ENUM(reflectEnum, constructors):
        return toEnumInstance(stream, descriptorSet, reflectEnum, constructors);
      case FLOAT, SINGLE, INT, UINT:
        return toFloatInstance(stream);
      case INT64:
        return toInt64Instance(stream);
      case STRING:
        return toStringInstance(stream);
      case BOOL:
        return toBoolInstance(stream);
      case ARRAY(elementDescriptor):
        return toArrayInstance(stream, descriptorSet, elementDescriptor);
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

  @:protected
  private static function optimizedJsonArrayStreamToEnumConstructorParameters(
    descriptorSet:DescriptorSet, parameterDescriptors:Iterable<TypeDescriptor>, streamIterator:Iterator<JsonStream>):Array<Dynamic>
  {
    var array = Std.instance(parameterDescriptors, (Array:Class<Array<TypeDescriptor>>));
    var generator = Std.instance(streamIterator, (Generator:Class<Generator<JsonStream>>));
    if (array != null)
    {
      if (generator !=  null)
      {
        return jsonArrayStreamToEnumConstructorParameters(descriptorSet, array, generator);
      }
      else
      {
        return jsonArrayStreamToEnumConstructorParameters(descriptorSet, array, streamIterator);
      }
    }
    else
    {
      if (generator !=  null)
      {
        return jsonArrayStreamToEnumConstructorParameters(descriptorSet, parameterDescriptors, generator);
      }
      else
      {
        return jsonArrayStreamToEnumConstructorParameters(descriptorSet, parameterDescriptors, streamIterator);
      }
    }
  }

  public static function toDynamicInstance(stream:JsonStream, descriptorSet:DescriptorSet):Dynamic
  {
    switch (stream)
    {
      case OBJECT(pairs):
        var generator = Std.instance(pairs, (Generator:Class<Generator<JsonStream.PairStream>>));
        if (generator != null)
        {
          return jsonObjectStreamToDynamicInstance(descriptorSet, generator);
        }
        else
        {
          return jsonObjectStreamToDynamicInstance(descriptorSet, pairs);
        }
      case _:
        return throw "Expect object!";
    }
  }
  
  #end
}

typedef EnumConstructorMap = StringMap<Iterable<TypeDescriptor>>;

enum TypeDescriptor
{
  DYNAMIC;
  CLASS<C>(reflectClass:Class<C>, fields:FieldMap);
  ENUM<E>(reflectEnum:Enum<E>, constructors:EnumConstructorMap);
  FLOAT;
  SINGLE;
  INT;
  UINT;
  INT64;
  BOOL;
  STRING;
  ARRAY(element:TypeDescriptor);
}

typedef FieldMap = haxe.ds.StringMap<TypeDescriptor>;


// 补充Haxe标准库的Reflect不够的信息
@:allow(com.qifun.jsonStream.Typed)
@:final class DescriptorSet
{
  
#if !macro
  private var fieldMaps = new haxe.ds.StringMap<FieldMap>();
  
  private var constructorMaps = new haxe.ds.StringMap<EnumConstructorMap>();
  
  public function new(fieldMaps, constructorMaps)
  {
    this.fieldMaps = fieldMaps;
    this.constructorMaps = constructorMaps;
  }
  
  public function toEnumInstance<E>(e:Enum<E>):JsonStream->E
  {
    var constructors = constructorMaps.get(e.getEnumName());
    return function(stream):E
    {
      return Typed.toEnumInstance(stream, this, e, constructors);
    }
  }
  
  public function toClassInstance<C>(c:Class<C>):JsonStream->C
  {
    var fields = fieldMaps.get(c.getClassName());
    return function(stream):C
    {
      return Typed.toClassInstance(stream, this, c, fields);
    }
  }

#end
}
