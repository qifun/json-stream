package com.qifun.jsonStream;

import com.qifun.jsonStream.JsonBuilder;
import com.dongxiguo.continuation.Continuation;
import com.qifun.jsonStream.unknown.UnknownType;

#if macro
import com.qifun.jsonStream.GeneratorUtilities.*;
import haxe.ds.StringMap;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
using StringTools;
#end

/**
  提供创建`JsonBuilder`的静态函数。

  用法：
  <pre>`// MyBuilderFactory.hx
using com.qifun.jsonStream.Plugins;
@:build(com.qifun.jsonStream.JsonBuilderFactory.generateBuilderFactory([ "myPackage.Module1", "myPackage.Module2", "myPackage.Module3" ]))
class MyBuilderFactory {}`</pre>

  <pre>`// Sample.hx
import com.qifun.jsonStream.JsonBuilder;
using com.qifun.jsonStream.Plugins;
using MyBuilderFactory;
class Sample
{
  public static function testBuild():myPackage.Module1.MyClass
  {
    var builder:JsonBuilder<myPackage.Module1.MyClass> = JsonBuilderFactory.newBuilder()
    {
      var arrayBuilder = builder.setObject();
      arrayBuilder.addNumber("field1", 123);
      arrayBuilder.addString("field2", "foo");
      // ...
      arrayBuilder.end();
    }
    return builder.result;
  }
}`</pre>

**/
class JsonBuilderFactory
{

  public static function newRawBuilder():JsonBuilder<RawJson> return
  {
    // .bind() 后缀能提高性能，见：https://github.com/HaxeFoundation/haxe/issues/3025
    new JsonBuilder(JsonBuilderRuntime.buildRaw.bind());
  }

  /**
    创建`IJsonBuilder`的工厂类。必须用在`@:build`中。

    @param includeModules 类型为`Array<String>`，数组的每一项是一个模块名。在这些模块中应当定义被创建的数据结构。
  **/
  @:noUsing
  macro public static function generateBuilderFactory(includeModules:Array<String>):Array<Field> return
  {
    var generator = new JsonBuilderFactoryGenerator(Context.getLocalClass().get(), Context.getBuildFields());
    for (moduleName in includeModules)
    {
      for (rootType in Context.getModule(moduleName))
      {
        generator.tryAddBuildMethod(rootType);
      }
    }
    generator.buildFields();
  }

  macro public static function newBuilder<Result>():ExprOf<JsonBuilder<Result>> return
  {
    var expectedType = Context.getExpectedType();
    if (expectedType == null)
    {
      Context.error("Require explicit return type!", Context.currentPos());
    }
    switch (Context.follow(expectedType))
    {
      case TInst(_, [ resultType ]):
        var resultComplexType = TypeTools.toComplexType(resultType);
        if (resultComplexType == null)
        {
          Context.error("Require explicit return type!", Context.currentPos());
        }
        var pluginStreamTypePath =
        {
          pack: [ "com", "qifun", "jsonStream" ],
          name: "JsonBuilderFactory",
          sub: "JsonBuilderPluginStream",
          params: [ TPType(resultComplexType) ],
        };
        macro new com.qifun.jsonStream.JsonBuilder(
          function(stream:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream, onComplete):Void
          {
            new $pluginStreamTypePath(stream).pluginBuild(onComplete);
          });
      case _: throw "Expect JsonBuilder!";
    }
  }
}

@:dox(hide)
abstract JsonBuilderPluginStream<Result>(AsynchronousJsonStream)
{

  @:extern
  public inline function new(underlying:AsynchronousJsonStream)
  {
    this = underlying;
  }

  public var underlying(get, never):AsynchronousJsonStream;

  @:extern
  inline function get_underlying():AsynchronousJsonStream return
  {
    this;
  }

}


#if macro
class JsonBuilderFactoryGenerator
{

  private var buildingClassExpr(get, never):Expr;

  private function get_buildingClassExpr():Expr return
  {
    var modulePath = MacroStringTools.toFieldExpr(buildingClass.module.split("."));
    var className = buildingClass.name;
    macro $modulePath.$className;
  }

  public static function generatedBuild(stream:ExprOf<AsynchronousJsonStream>, onComplete:Expr, expectedType:Type):Expr return
  {
    switch (Context.follow(expectedType))
    {
      case TInst(_.get() => classType, _) if (!isAbstract(classType)):
        var methodName = buildMethodName(classType.pack, classType.name);
        for (usingClassRef in Context.getLocalUsing())
        {
          var usingClass = usingClassRef.get();
          var field = TypeTools.findField(usingClass, methodName, true);
          if (field != null)
          {
            if (classType.meta.has(":final"))
            {
              var path = usingClass.module.split(".");
              path.push(usingClass.name);
              var pathExpr = MacroStringTools.toFieldExpr(path);
              return macro $pathExpr.$methodName($stream, $onComplete);
            }
            else
            {
              return dynamicBuild(stream, onComplete, expectedType);
            }
          }
        }
        var contextBuilder = getContextBuilder();
        if (contextBuilder == null)
        {
          Context.error('No plugin or deserializer for $expectedType.', Context.currentPos());
        }
        if (contextBuilder.deserializingTypes.get(methodName) == null)
        {
          contextBuilder.deserializingTypes.set(methodName, classType);
          contextBuilder.buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(contextBuilder.newClassBuildFunction(classType)),
            });
        }
        if (classType.meta.has(":final"))
        {
          var buildingClassExpr = contextBuilder.buildingClassExpr;
          macro untyped($buildingClassExpr).$methodName($stream, $onComplete);
        }
        else
        {
          dynamicBuild(stream, onComplete, expectedType);
        }
      case TEnum(_.get() => enumType, _):
        var methodName = buildMethodName(enumType.pack, enumType.name);
        for (usingClassRef in Context.getLocalUsing())
        {
          var usingClass = usingClassRef.get();
          var field = TypeTools.findField(usingClass, methodName, true);
          if (field != null)
          {
            var path = usingClass.module.split(".");
            path.push(usingClass.name);
            var pathExpr = MacroStringTools.toFieldExpr(path);
            return macro $pathExpr.$methodName($stream, $onComplete);
          }
        }
        var contextBuilder = getContextBuilder();
        if (contextBuilder.deserializingTypes.get(methodName) == null)
        {
          contextBuilder.deserializingTypes.set(methodName, enumType);
          contextBuilder.buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(contextBuilder.newEnumBuildFunction(enumType)),
            });
        }
        var buildingClassExpr = contextBuilder.buildingClassExpr;
        macro untyped($buildingClassExpr).$methodName($stream, $onComplete);
      case TAbstract(_.get() => abstractType, _):
        var methodName = buildMethodName(abstractType.pack, abstractType.name);
        for (usingClassRef in Context.getLocalUsing())
        {
          var usingClass = usingClassRef.get();
          var field = TypeTools.findField(usingClass, methodName, true);
          if (field != null)
          {
            if (abstractType.impl.get().meta.has(":final"))
            {
              var path = usingClass.module.split(".");
              path.push(usingClass.name);
              var pathExpr = MacroStringTools.toFieldExpr(path);
              return macro $pathExpr.$methodName($stream, $onComplete);
            }
            else
            {
              return dynamicBuild(stream, onComplete, expectedType);
            }
          }
        }
        var contextBuilder = getContextBuilder();
        if (contextBuilder.deserializingTypes.get(methodName) == null)
        {
          contextBuilder.deserializingTypes.set(methodName, abstractType);
          contextBuilder.buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(contextBuilder.newAbstractBuildFunction(abstractType)),
            });
        }
        if (abstractType.impl.get().meta.has(":final"))
        {
          var buildingClassExpr = contextBuilder.buildingClassExpr;
          macro untyped($buildingClassExpr).$methodName($stream, $onComplete);
        }
        else
        {
          dynamicBuild(stream, onComplete, expectedType);
        }
      case t:
        dynamicBuild(stream, onComplete, expectedType);
    }
  }

  private static function getContextBuilder():JsonBuilderFactoryGenerator return
  {
    var localClass = Context.getLocalClass().get();
    allBuilders.get(localClass.module + "." + localClass.name);
  }

  public static function dynamicBuild(stream:ExprOf<AsynchronousJsonStream>, onComplete:ExprOf<Dynamic->Void>, expectedType:Type):Expr return
  {
    var expectedComplexType = TypeTools.toComplexType(Context.follow(expectedType));
    if (expectedComplexType == null)
    {
      expectedComplexType = DYNAMIC_COMPLEX_TYPE;
    }
    var localUsings = Context.getLocalUsing();
    function createFunction(i:Int, key:ExprOf<String>, value:ExprOf<JsonStream>):Expr return
    {
      if (i < localUsings.length)
      {
        var classType = localUsings[i].get();
        var field = TypeTools.findField(classType, "dynamicBuild", true);
        if (field == null)
        {
          createFunction(i + 1, key, value);
        }
        else
        {
          var modulePath = MacroStringTools.toFieldExpr(classType.module.split("."));
          var className = classType.name;
          var next = createFunction(i + 1, key, value);
          macro
          {
            var result = $modulePath.$className.dynamicBuild($key, $value).async();
            if (result != null)
            {
              result;
            }
            else
            {
              $next;
            }
          }
        }
      }
      else
      {
        var contextBuilder = getContextBuilder();
        var typePath = switch (expectedComplexType)
        {
          case TPath( { pack: pack, name: name, sub: sub } ): { pack: pack, name: name, sub: sub }
          case _ : null;
        }
        var fallbackExpr =
          if (Context.unify(expectedType, lowPriorityDynamicType))
          {
            macro new com.qifun.jsonStream.unknown.UnknownType($key, com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderRuntime.buildRaw($value).async());
          }
          else if (
            Context.unify(expectedType, hasUnknownTypeFieldType) ||
            Context.unify(expectedType, hasUnknownTypeSetterType))
          {
            macro
            {
              var result = new $typePath();
              result.unknownType = new com.qifun.jsonStream.unknown.UnknownType($key, com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderRuntime.buildRaw($value).async());
              result;
            }
          }
          else
          {
            macro null;
          }
        if (contextBuilder == null)
        {
          fallbackExpr;
        }
        else
        {
          var classType = getContextBuilder().buildingClass;
          var modulePath = MacroStringTools.toFieldExpr(classType.module.split("."));
          var className = classType.name;
          macro
          {
            inline function untypedBuild(onComplete):Void
            {
              untyped($modulePath.$className).dynamicBuild($key, $value, onComplete);
            }
            var knownValue = untypedBuild().async();
            if (knownValue == null)
            {
              $fallbackExpr;
            }
            else
            {
              knownValue;
            }
          }
        }
      }
    }
    var processDynamic = createFunction(0, macro dynamicKey, macro dynamicValue);
    macro com.dongxiguo.continuation.Continuation.cpsFunction(function(stream:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream):Dynamic return
    {
      switch (stream)
      {
        case OBJECT(readPair):
          var dynamicKey, dynamicValue = readPair().async();
          if (dynamicKey == null)
          {
            throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.NOT_ENOUGH_FIELDS(readPair, 1, 0);
          }
          var nullKey, nullValue = readPair().async();
          if (nullKey != null)
          {
            throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.TOO_MANY_FIELDS(readPair, 1);
          }
          $processDynamic;
        case NULL:
          null;
        case _:
          throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "OBJECT", "NULL" ]);
      }
    })($stream, $onComplete);
  }

  private var buildingFields:Array<Field>;

  private var buildingClass:ClassType;

  private var deserializingTypes(default, null) = new StringMap<BaseType>();

  private static var allBuilders = new StringMap<JsonBuilderFactoryGenerator>();

  // id的格式：packageNames.ModuleName.ClassName
  private var id(get, never):String;

  private function get_id() return
  {
    buildingClass.module + "." + buildingClass.name;
  }

  public function new(buildingClass:ClassType, buildingFields:Array<Field>)
  {
    this.buildingClass = buildingClass;
    this.buildingFields = buildingFields;
    allBuilders.set(id, this);
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

  private static function buildMethodName(pack:Array<String>, name:String):String
  {
    var sb = new StringBuf();
    sb.add("build_");
    for (p in pack)
    {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }

  // 类似deserialize，但是能递归解决类型，以便能够在@:build宏返回以前就立即执行
  private static function resolvedBuild(expectedComplexType:ComplexType, stream:ExprOf<JsonStream>, ?params:Array<TypeParamDecl>):Expr return
  {
    var typedJsonStreamTypePath =
    {
      pack: [ "com", "qifun", "jsonStream" ],
      name: "JsonBuilderFactory",
      sub: "JsonBuilderPluginStream",
      params: [ TPType(expectedComplexType) ],
    };
    var typedJsonStreamType = TPath(typedJsonStreamTypePath);
    var f =
    {
      expr:
        EFunction("temporaryDeserialize",
        {
          args:
          [
            { name: "typedJsonStream", type: typedJsonStreamType },
            { name: "onComplete", type: null }
          ],
          ret: VOID_COMPLEX_TYPE,
          expr: macro return typedJsonStream.pluginBuild(onComplete),
          params: params,
        }),
      pos: Context.currentPos()
    }
    var placeholderExpr = macro
    {
      $f;
      null;
    }
    // trace(ExprTools.toString(Context.getTypedExpr(Context.typeExpr(placeholderExpr))));
    switch (Context.getTypedExpr(Context.typeExpr(placeholderExpr)))
    {
      case { expr: EBlock([ { expr: EFunction(_, resolved) | EVars([ { expr: {expr: EFunction(null, resolved)}}])}, _ ]) } :
        var typedJsonStream =
        {
          pos: Context.currentPos(),
          expr:
            ENew(typedJsonStreamTypePath,
              [ stream ]),
        }
        var f =
        {
          expr: EFunction("inline_temporaryDeserialize", resolved),
          pos: Context.currentPos(),
        }
        macro
        {
          $f;
          function(handler) temporaryDeserialize($typedJsonStream, handler);
        }
      case t:
        throw "Expect EBlock, actual " + ExprTools.toString(t);
    };
  }

  private function newEnumBuildFunction(enumType:EnumType):Function return
  {
    var enumParams: Array<TypeParamDecl> =
    [
      for (tp in enumType.params)
      {
        name: tp.name,
        // TODO: constraits
      }
    ];
    var enumPath = enumType.module.split(".");
    enumPath.push(enumType.name);
    var enumFieldExpr = MacroStringTools.toFieldExpr(enumPath);
    var cases = [];
    var unknownEnumValueConstructor = null;
    for (constructor in enumType.constructs)
    {
      switch (constructor)
      {
        case { name: "UNKNOWN_ENUM_VALUE", type: TFun([ { t: TEnum(_.get() => { module: "com.qifun.jsonStream.unknown.UnknownEnumValue", name: "UnknownEnumValue" }, _) } ], _) }:
        {
          // 支持UnknownEnumValue!
          unknownEnumValueConstructor = constructor.name;
        }
        case { type: TFun(args, _) }:
          var valueParams: Array<TypeParamDecl> =
          [
            for (tp in constructor.params)
            {
              name: tp.name,
              // TODO: constraits
            }
          ];
          var enumAndValueParams = enumParams.concat(valueParams);
          var constructorName = constructor.name;
          cases.push(
            {
              var block = [];
              var unknownFieldMapName = null;
              for (i in 0...args.length)
              {
                var parameterName = 'parameter$i';
                block.push(macro var $parameterName = null);
              }
              var parameterCases:Array<Case> = [];
              for (i in 0...args.length)
              {
                var parameterName = 'parameter$i';
                var arg = args[i];
                if (arg.name == "unknownFieldMap" && Context.follow(arg.t).match(TAbstract(_.get() => {module: "com.qifun.jsonStream.unknown.UnknownFieldMap", name: "UnknownFieldMap"}, [])))
                {
                  if (unknownFieldMapName == null)
                  {
                    unknownFieldMapName = parameterName;
                    block.push(macro $i{parameterName} = new com.qifun.jsonStream.unknown.UnknownFieldMap(new haxe.ds.StringMap.StringMap()));
                  }
                  else
                  {
                    Context.error("Expect zero or one UnknownFieldMap in enum parameter list!", constructor.pos);
                  }
                }
                else
                {
                  var parameterValue = resolvedBuild(TypeTools.toComplexType(arg.t), macro parameterValue, enumAndValueParams);
                  var f =
                  {
                    pos: Context.currentPos(),
                    expr: EFunction(
                      "inline_temporaryEnumDeserialize",
                      {
                        params: valueParams,
                        ret: null,
                        args: [ { name: "onComplete", type: null} ],
                        expr: macro $parameterValue(onComplete),
                      })
                  };
                  parameterCases.push(
                    {
                      values: [ Context.makeExpr(arg.name, Context.currentPos()) ],
                      expr: macro
                      {
                        $f;
                        $i{parameterName} = com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderRuntime.nullize(temporaryEnumDeserialize().async());
                      }
                    });
                }
              }
              var switchKey =
              {
                pos: Context.currentPos(),
                expr: ESwitch(
                  macro parameterKey,
                  parameterCases,
                  if (unknownFieldMapName == null)
                  {
                    expr: EBlock([]),
                    pos: Context.currentPos(),
                  }
                  else
                  {
                    macro $i{unknownFieldMapName}.underlying.set(parameterKey, com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderRuntime.buildRaw(parameterValue).async());
                  }),
              };
              var newEnum =
              {
                pos: Context.currentPos(),
                expr: ECall(
                  macro $enumFieldExpr.$constructorName,
                  [
                    for (i in 0...args.length)
                    {
                      var parameterName = 'parameter$i';
                      macro com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderRuntime.nullize($i{parameterName});
                    }
                  ]),
              };
              block.push(
                macro
                {
                  var parameterKey, parameterValue = readParameter().async();
                  while (parameterKey != null)
                  {
                    $switchKey;
                    var k, v = readParameter().async();
                    parameterKey = k;
                    parameterValue = v;
                  }
                  $newEnum;
                });
              var blockExpr =
              {
                pos: Context.currentPos(),
                expr: EBlock(block),
              };
              ({
                values: [ macro $v{constructorName} ],
                expr: macro
                {
                  switch (constructorValue)
                  {
                    case com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream.OBJECT(readParameter):
                      $blockExpr;
                    case _:
                      throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.UNMATCHED_JSON_TYPE(constructorValue, [ "OBJECT" ]);
                  }
                },
              }:Case);
            });
        case _: // 没有参数的枚举值，前面已经处理过了。
      }
    }
    var processObjectBody =
    {
      pos: Context.currentPos(),
      expr: ESwitch(
        macro constructorKey,
        cases,
        if (unknownEnumValueConstructor == null)
        {
          macro null;
        }
        else
        {
          macro $enumFieldExpr.UNKNOWN_ENUM_VALUE(
            com.qifun.jsonStream.unknown.UnknownEnumValue.UNKNOWN_PARAMETERIZED_CONSTRUCTOR(
              constructorKey,
              com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderRuntime.buildRaw(constructorValue).async()));
        }),
    }
    var zeroParameterBranch =
    {
      pos: Context.currentPos(),
      expr: ESwitch(
        macro constructorName,
        [
          for (constructor in enumType.constructs) if (constructor.type.match(TEnum(_, _)))
          {
            var constructorName = constructor.name;
            {
              values: [ macro $v{constructorName} ],
              expr: macro $enumFieldExpr.$constructorName,
            }
          }
        ],
        if (unknownEnumValueConstructor == null)
        {
          macro null;
        }
        else
        {
          macro $enumFieldExpr.UNKNOWN_ENUM_VALUE(
            com.qifun.jsonStream.unknown.UnknownEnumValue.UNKNOWN_CONSTANT_CONSTRUCTOR(constructorName));
        }),
    }
    var methodBody = macro switch (stream)
    {
      case STRING(constructorName):
        $zeroParameterBranch;
      case OBJECT(readConstructor):
        var constructorKey:Null<String>, constructorValue:Null<com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream> = readConstructor().async();
        if (constructorKey == null)
        {
          throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.NOT_ENOUGH_FIELDS(readConstructor, 1, 0);
        }
        var nullKey:String, nullValue:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream = readConstructor().async();
        if (nullKey != null)
        {
          throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.TOO_MANY_FIELDS(readConstructor, 1);
        }
        $processObjectBody;
      case NULL:
        null;
      case _:
        throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "STRING", "OBJECT", "NULL" ]);
    }

    var expectedTypePath =
    {
      pack: enumType.pack,
      name: enumType.module.substring(enumType.module.lastIndexOf(".") + 1),
      sub: enumType.name,
      params: [ for (p in enumType.params) TPType(TPath({ pack: [], name: p.name})) ]
    };
    var expectedComplexType = TPath(expectedTypePath);
    {
      args:
      [
        {
          name:"stream",
          type: TPath(
            {
              pack: [ "com", "qifun", "jsonStream" ],
              name: "JsonBuilder",
              sub: "AsynchronousJsonStream",
            }),
        },
        {
          name: "onComplete",
          type: TFunction([expectedComplexType], VOID_COMPLEX_TYPE)
        }
      ],
      ret: VOID_COMPLEX_TYPE,
      expr: macro
        com.dongxiguo.continuation.Continuation.cpsFunction(
          function(stream:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream):Null<$expectedComplexType>
          {
            return $methodBody;
          })(stream, onComplete),
      params: enumParams,
    }
  }

  private function newAbstractBuildFunction(abstractType:AbstractType):Function return
  {
    var params: Array<TypeParamDecl> =
    [
      for (tp in abstractType.params)
      {
        name: tp.name,
        // TODO: constraits
      }
    ];
    var implExpr = resolvedBuild(TypeTools.toComplexType(abstractType.type), macro stream, params);
    var abstractModule = abstractType.module;
    var expectedTypePath =
    {
      pack: abstractType.pack,
      name: abstractModule.substring(abstractModule.lastIndexOf(".") + 1),
      sub: abstractType.name,
      params: [ for (p in params) TPType(TPath({ pack: [], name: p.name})) ]
    };
    var expectedComplexType = TPath(expectedTypePath);
    {
      args:
      [
        {
          name:"stream",
          type: TPath(
            {
              pack: [ "com", "qifun", "jsonStream" ],
              name: "JsonBuilder",
              sub: "AsynchronousJsonStream",
            }),
        },
        {
          name: "onComplete",
          type: TFunction([expectedComplexType], VOID_COMPLEX_TYPE)
        }
      ],
      ret: VOID_COMPLEX_TYPE,
      expr: macro
        com.dongxiguo.continuation.Continuation.cpsFunction(
          function(stream:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream):$expectedComplexType
          {
            return cast $implExpr().async();
          })(stream, onComplete),
      params: params,
    }
  }

  private function newClassBuildFunction(classType:ClassType):Function return
  {
    var params: Array<TypeParamDecl> =
    [
      for (tp in classType.params)
      {
        name: tp.name,
        // TODO: constraits
      }
    ];
    var cases:Array<Case> = [];
    var hasUnknownFieldMap = false;
    function addFieldCases(classType:Null<ClassType>, ?concreteTypes:Array<Type>):Void
    {
      function applyTypeParameters(t:Type) return
      {
        if (concreteTypes == null)
        {
          t;
        }
        else
        {
          TypeTools.applyTypeParameters(t, classType.params, concreteTypes);
        }
      }
      for (field in classType.fields.get())
      {
        switch (field)
        {
          case
          {
            name: "unknownFieldMap",
            kind: FVar(AccNormal | AccNo | AccCall, _),
            type: Context.follow(_) => TAbstract(_.get() => { module: "com.qifun.jsonStream.unknown.UnknownFieldMap", name: "UnknownFieldMap" }, []),
          }:
            hasUnknownFieldMap = true;
          case { kind: FVar(AccNormal | AccNo, AccNormal | AccNo), }:
            var fieldName = field.name;
            var d = resolvedBuild(TypeTools.toComplexType(applyTypeParameters(field.type)), macro value, params);
            cases.push(
              {
                values: [ macro $v{fieldName} ],
                guard: null,
                expr: macro result.$fieldName = $d().async(),
              });
          case _:
            continue;
        }
      }
      var superClass = classType.superClass;
      if (superClass != null)
      {
        addFieldCases(
          superClass.t.get(),
          [ for (p in superClass.params) applyTypeParameters(p) ]);
      }
    }
    addFieldCases(classType);
    var classModule = classType.module;
    var expectedTypePath =
    {
      pack: classType.pack,
      name: classModule.substring(classModule.lastIndexOf(".") + 1),
      sub: classType.name,
      params: [ for (tp in classType.params) TPType(TPath({ name: tp.name, pack: []})) ]
    };
    var newInstance =
    {
      pos: Context.currentPos(),
      expr: ENew(expectedTypePath, []),
    }
    var switchKey =
    {
      pos: Context.currentPos(),
      expr: ESwitch(macro key, cases,
        if (hasUnknownFieldMap)
        {
          macro result.unknownFieldMap.underlying.set(key, com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderRuntime.buildRaw(value).async());
        }
        else
        {
          macro null;
        }),
    }

    var switchStream = macro switch (stream)
    {
      case OBJECT(read):
        var result = $newInstance;
        var key, value = read().async();
        while (key != null)
        {
          $switchKey;
          var k, v = read().async();
          key = k;
          value = v;
        }
        result;
      case NULL:
        null;
      case _:
        throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "OBJECT", "NULL" ]);
    }

    var expectedComplexType = TPath(expectedTypePath);
    {
      args:
      [
        {
          name:"stream",
          type: TPath(
            {
              pack: [ "com", "qifun", "jsonStream" ],
              name: "JsonBuilder",
              sub: "AsynchronousJsonStream",
            }),
        },
        {
          name: "onComplete",
          type: TFunction([expectedComplexType], VOID_COMPLEX_TYPE)
        }
      ],
      ret: VOID_COMPLEX_TYPE,
      expr: macro
        com.dongxiguo.continuation.Continuation.cpsFunction(
          function(stream:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream):$expectedComplexType
          {
            return $switchStream;
          })(stream, onComplete),
      params: params,
    }
  }


  public function tryAddBuildMethod(type:Type):Void
  {
    switch (Context.follow(type))
    {
      case TInst(_.get() => classType, _) if (!isAbstract(classType)):
        var methodName = buildMethodName(classType.pack, classType.name);
        if (deserializingTypes.get(methodName) == null)
        {
          deserializingTypes.set(methodName, classType);
          buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(newClassBuildFunction(classType)),
            });
        }
      case TEnum(_.get() => enumType, _):
        var methodName = buildMethodName(enumType.pack, enumType.name);
        if (deserializingTypes.get(methodName) == null)
        {
          deserializingTypes.set(methodName, enumType);
          buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(newEnumBuildFunction(enumType)),
            });
        }
      case TAbstract(_.get() => abstractType, _):
        var methodName = buildMethodName(abstractType.pack, abstractType.name);
        if (deserializingTypes.get(methodName) == null)
        {
          deserializingTypes.set(methodName, abstractType);
          buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(newAbstractBuildFunction(abstractType)),
            });
        }
      case _:
    }
  }

  public function buildFields():Array<Field> return
  {
    var meta = buildingClass.meta;

    //meta.add(
      //":access",
      //[ macro com.qifun.jsonStream.JsonDeserializerRuntime ],
      //Context.currentPos());

    for (deserializingType in deserializingTypes)
    {
      var accessPack = MacroStringTools.toFieldExpr(deserializingType.pack);
      var accessName = deserializingType.name;
      meta.add(
        ":access",
        [ accessPack == null ? macro $i{accessName} : macro $accessPack.$accessName ],
        Context.currentPos());
    }

    var dynamicCases:Array<Case> = [];

    for (localUsing in Context.getLocalUsing())
    {
      var baseType:BaseType = switch (localUsing.get())
      {
        case { kind: KAbstractImpl(a) } : a.get();
        case classType: classType;
      }
      var moduleExpr = MacroStringTools.toFieldExpr(baseType.module.split("."));
      var nameField = baseType.name;
      var pluginDeserializeField = TypeTools.findField(localUsing.get(), "pluginBuild", true);
      if (pluginDeserializeField != null && !pluginDeserializeField.meta.has(":noDynamicAsynchronousDeserialize"))
      {
        var temporaryFunction = macro function (valueStream:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream, onComplete):Void
        {
          $moduleExpr.$nameField.pluginBuild(new com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderPluginStream(valueStream), onComplete);
        };
        var typedTemporaryFunction = Context.typeExpr(temporaryFunction);
        var resolvedTemporaryFunction = Context.getTypedExpr(typedTemporaryFunction);
        var fullName:String = switch (Context.follow(typedTemporaryFunction.t))
        {
          case TFun([ _, Context.follow(_.t) => TFun([ Context.follow(_.t) => TAbstract(_.get() => { module: module, name: name }, _) ], _) ], _): getFullName(module, name);
          case TFun([ _, Context.follow(_.t) => TFun([ Context.follow(_.t) => TEnum(_.get() => { module: module, name: name }, _) ], _) ], _): getFullName(module, name);
          case TFun([ _, Context.follow(_.t) => TFun([ Context.follow(_.t) => TInst(_.get() => { module: module, name: name }, _) ], _) ], _): getFullName(module, name);
          case t: continue;
        }
        dynamicCases.push(
        {
          values: [ macro $v{fullName} ],
          expr: macro $resolvedTemporaryFunction(valueStream, onComplete),
        });
      }
    }

    for (methodName in deserializingTypes.keys())
    {
      var baseType = deserializingTypes.get(methodName);
      var fullName = getFullName(baseType.module, baseType.name);
      dynamicCases.push(
        {
          values: [ macro $v{ fullName } ],
          expr: macro ($i{methodName}(valueStream, onComplete)),
        });
    }
    var switchExpr =
    {
      pos: Context.currentPos(),
      expr: ESwitch(macro dynamicTypeName, dynamicCases, macro null),
    }
    buildingFields.push(
      {
        name: "dynamicBuild",
        pos: Context.currentPos(),
        meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
        access: [ APublic, AStatic ],
        kind: FFun(
          {
            args:
            [
              {
                name: "dynamicTypeName",
                type: TPath({ pack: [], name: "String",}),
              },
              {
                name: "valueStream",
                type: TPath({ pack: [ "com","qifun","jsonStream" ], sub: "AsynchronousJsonStream", name: "JsonBuilder",}),
              },
              {
                name: "onComplete",
                type: TFunction(
                  [ DYNAMIC_COMPLEX_TYPE ],
                  VOID_COMPLEX_TYPE
                )
              }
            ],
            ret: VOID_COMPLEX_TYPE,
            expr: macro $switchExpr,
          }),
      });
    allBuilders.remove(id);
    buildingFields;
  }

}
#end

/**
  使用`JsonBuilder`时可能抛出的异常。
**/
enum JsonBuilderError
{
  TOO_MANY_FIELDS<Handler>(read:Handler->Void, expected:Int);
  NOT_ENOUGH_FIELDS<Handler>(read:Handler->Void, expected:Int, actual:Int);
  UNMATCHED_JSON_TYPE(stream:AsynchronousJsonStream, expected:Array<String>);
}


@:dox(hide)
@:final
class JsonBuilderRuntime
{

  @:extern
  public static inline function nullize<T>(t:Null<T>):Null<T> return t;

  public static function buildRaw(stream:AsynchronousJsonStream, onComplete:RawJson->Void):Void
  {
    Continuation.cpsFunction(function(stream:AsynchronousJsonStream):RawJson return
    {
      new RawJson(switch (stream)
      {
        case TRUE: true;
        case FALSE: false;
        case NULL: null;
        case NUMBER(value): value;
        case STRING(value): value;
        case ARRAY(read):
          var array = [];
          var element = read().async();
          while (element != null)
          {
            array.push(buildRaw(element).async());
            element = read().async();
          }
          array;
        case OBJECT(read):
          //var object = {}; // 如果这样会编译错误，因为{}被理解成了EBlock而不是EObjectDecl
          var object = (function() return {})();
          while (true)
          {
            var key, value = read().async();
            if (key == null)
            {
              return new RawJson(object);
            }
            Reflect.setField(object, key, buildRaw(value).async());
          }
          throw "unreachable code";
      });
    })(stream, onComplete);
  }
}
