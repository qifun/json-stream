package com.qifun.jsonStream;

using Type;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Type;
#end
using StringTools;
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
  macro public static function getToInstanceFunction(includeModules: Array<String>):haxe.macro.ExprOf<Registry>
  {
    // TODO: 为以上文件中的类提供分发服务
    var block = [];
    var fieldDescriptorInitializers = [];
    var enumRegistryInitializers = [];
    var classRegistryInitializers = [];

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
            enumRegistryInitializers.push(macro $v{qname} => $i{varName});
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
              classRegistryInitializers.push(macro $v{qname} => $i{varName});
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

    var enumRegistry = toStringMap(enumRegistryInitializers);
    var classRegistry = toStringMap(classRegistryInitializers);
    block.push(macro new com.qifun.jsonStream.Typed.Registry($classRegistry, $enumRegistry));
    trace(ExprTools.toString({ expr: EBlock(block), pos: Context.currentPos(), }));
    return 
    {
      expr: EBlock(block),
      pos: Context.currentPos(),
    };
  }
  
}

typedef EnumConstructorMap = StringMap<Iterable<TypeDescriptor>>;

abstract EnumDescriptor<E>(EnumConstructorMap) from EnumConstructorMap
{
  
}

enum TypeDescriptor
{
  DYNAMIC;
  CLASS<C>(reflectClass:Class<C>, classDescriptor:ClassDescriptor<C>);
  ENUM<E>(reflectEnum:Enum<E>, constructors:EnumDescriptor<E>);
  FLOAT;
  INT;
  UINT;
  INT64;
  BOOL;
  STRING;
}

typedef FieldMap = haxe.ds.StringMap<TypeDescriptor>;

abstract ClassDescriptor<C>(FieldMap) from FieldMap
{
  
}


// 补充Haxe标准库的Reflect不够的信息
@:final class Registry
{
  
  private var classDescriptor = new haxe.ds.StringMap<ClassDescriptor<Dynamic>>();
  
  private var enumDescriptors = new haxe.ds.StringMap<EnumDescriptor<Dynamic>>();
  
  public function new(classDescriptor, enumDescriptors)
  {
    this.classDescriptor = classDescriptor;
    this.enumDescriptors = enumDescriptors;
  }
  
  public function getEnumDescriptor<E>(e:Enum<E>):Null<EnumDescriptor<E>>
  {
    return cast enumDescriptors.get(e.getEnumName());
  }
  
  public function getClassDescriptor<C>(c:Class<C>):Null<ClassDescriptor<C>>
  {
    return cast classDescriptor.get(c.getClassName());
  }
}