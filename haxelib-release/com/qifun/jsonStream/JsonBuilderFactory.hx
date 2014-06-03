package com.qifun.jsonStream;

import com.qifun.jsonStream.JsonBuilder;
import com.dongxiguo.continuation.Continuation;

#if macro
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
 * @author 杨博
 */
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
        generator.tryAddDeserializeMethod(rootType);
      }
    }
    generator.buildFields();
  }

  macro public static function newBuilder<Result>():ExprOf<JsonBuilder<Result>> return
  {
    var expectedType = Context.follow(Context.getExpectedType());
    switch (expectedType)
    {
      case TInst(_, [ resultType ]):
        var pluginStreamComplexType = TPath(
        {
          pack: [ "com", "qifun", "jsonStream" ],
          name: "JsonBuilderFactory",
          sub: "JsonBuilderPluginStream",
          params: [ TPType(TypeTools.toComplexType(Context.getExpectedType())) ],
        });
        macro new JsonBuilder(function(stream:$pluginStreamComplexType, onComplete):Void
        {
          stream.pluginAsynchronousDeserialize(onComplete);
        });
      case _: throw "Expect JsonBuilder!";
    }
  }
}

/*

目标：
1. 不要创建海量的闭包
2. 最好不要两次反射

对于非引用类型，需要回写
对于引用类型，不需要回写

有三种实现方法：
1. 引用类型，不回写
2. 非引用类型，使用accessor，不回写
3. 非引用类型，使用accessor，回写

引用类型无论是否回写，都需要accessor

switch两次是难免的

第一次switch创建Builder
第二次switch回写值

只有部分beginObject（dynamic）才需要rewrite

accessor有两种，闭包和反射，如果用闭包，CPU性能高，但会生成很多类
闭包在dynamic以外的场合，可以内联掉
可以统一给予闭包accessor，但dynamic会分析闭包，转换成字符串供反射

setter统一使用反射较好。盖Haxe反射性能原本就不错。

不说插件，就说生成的类Builder函数签名是什么

function asBuilder_Xxx(xxx:Xxx):IJsonBuilder
function setBoolField_Xxx(xxx:Xxx, field:String, value:Bool):Void
反正创建类是免不了的，那么自己创建总比被迫创建要好

不管了，就用海量闭包实现，反正这东西只是为了接口完备，性能差也不管了
*/
typedef RequireRewrite = Bool;

typedef JsonBuilderPlugin<Result> =
{
  function pluginAsynchronousDeserialize(stream:JsonBuilderPluginStream<Result>, onComplete:Result->Void):Void;
}

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
  private static var VOID_COMPLEX_TYPE(default, never) =
    TPath({ name: "Void", pack: []});

  private static function getFullName(module:String, name:String):String return
  {
    if (module == name || module.endsWith(name) && module.charCodeAt(module.length - name.length - 1) == ".".code)
    {
      module;
    }
    else
    {
      module + "." + name;
    }
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

  private static function deserializeMethodName(pack:Array<String>, name:String):String
  {
    var sb = new StringBuf();
    sb.add("asynchronousDeserialize_");
    for (p in pack)
    {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }

  // 类似deserialize，但是能递归解决类型，以便能够在@:build宏返回以前就立即执行
  private static function resolvedDeserialize(expectedComplexType:ComplexType, stream:ExprOf<JsonStream>, ?params:Array<TypeParamDecl>):Expr return
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

  private function newEnumDeserializeFunction(enumType:EnumType):Function return
  {
    var enumParams: Array<TypeParamDecl> =
    [
      for (tp in enumType.params)
      {
        name: tp.name,
        // TODO: constraits
      }
    ];
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
          var enumPath = enumType.module.split(".");
          enumPath.push(enumType.name);
          enumPath.push(constructorName);
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
                  var parameterValue = resolvedDeserialize(TypeTools.toComplexType(arg.t), macro parameterValue, enumAndValueParams);
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
                        inline function nullize<T>(t:Null<T>):Null<T> return t;
                        $i{parameterName} = nullize(temporaryEnumDeserialize().async());
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
                    macro $i{unknownFieldMapName}.underlying.set(parameterPair.key, com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderRuntime.buildRaw(parameterValue));
                  }),
              };
              var newEnum =
              {
                pos: Context.currentPos(),
                expr: ECall(
                  MacroStringTools.toFieldExpr(enumPath),
                  [
                    for (i in 0...args.length)
                    {
                      var parameterName = 'parameter$i';
                      macro
                      {
                        inline function nullize<T>(t:Null<T>):Null<T> return t;
                        nullize($i{parameterName});
                      }
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
          macro com.qifun.jsonStream.unknown.UnknownEnumValue.UNKNOWN_PARAMETERIZED_CONSTRUCTOR(
            constructorKey,
            com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderRuntime.buildRaw(constructorValue).async());
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
            var enumPath = enumType.module.split(".");
            enumPath.push(enumType.name);
            enumPath.push(constructorName);
            {
              values: [ macro $v{constructorName} ],
              expr: MacroStringTools.toFieldExpr(enumPath),
            }
          }
        ],
        if (unknownEnumValueConstructor == null)
        {
          macro null;
        }
        else
        {
          macro com.qifun.jsonStream.unknown.UnknownEnumValue.UNKNOWN_CONSTANT_CONSTRUCTOR(constructorName);
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
          type: TFunction([expectedComplexType], TPath({ name: "Void", pack: []}))
        }
      ],
      ret: TPath({ name: "Void", pack: []}),
      expr: macro
        com.dongxiguo.continuation.Continuation.cpsFunction(
          function(stream:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream):Null<$expectedComplexType>
          {
            return $methodBody;
          })(stream, onComplete),
      params: enumParams,
    }
  }

  private function newAbstractDeserializeFunction(abstractType:AbstractType):Function return
  {
    var params: Array<TypeParamDecl> =
    [
      for (tp in abstractType.params)
      {
        name: tp.name,
        // TODO: constraits
      }
    ];
    var implExpr = resolvedDeserialize(TypeTools.toComplexType(abstractType.type), macro stream, params);
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
          type: TFunction([expectedComplexType], TPath({ name: "Void", pack: []}))
        }
      ],
      ret: TPath({ name: "Void", pack: []}),
      expr: macro
        com.dongxiguo.continuation.Continuation.cpsFunction(
          function(stream:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream):$expectedComplexType
          {
            return cast $implExpr().async();
          })(stream, onComplete),
      params: params,
    }
  }

  private function newClassDeserializeFunction(classType:ClassType):Function return
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
            var d = resolvedDeserialize(TypeTools.toComplexType(applyTypeParameters(field.type)), macro value, params);
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
      name: classModule.substring(classModule.lastIndexOf(".")),
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
      case _:
        throw com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderError.UNMATCHED_JSON_TYPE(stream, [ "OBJECT" ]);
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
          type: TFunction([expectedComplexType], TPath({ name: "Void", pack: []}))
        }
      ],
      ret: TPath({ name: "Void", pack: []}),
      expr: macro
        com.dongxiguo.continuation.Continuation.cpsFunction(
          function(stream:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream):$expectedComplexType
          {
            return $switchStream;
          })(stream, onComplete),
      params: params,
    }
  }


  public function tryAddDeserializeMethod(type:Type):Void
  {
    switch (Context.follow(type))
    {
      case TInst(_.get() => classType, _) if (!classType.isInterface && classType.kind.match(KNormal)):
        var methodName = deserializeMethodName(classType.pack, classType.name);
        if (deserializingTypes.get(methodName) == null)
        {
          deserializingTypes.set(methodName, classType);
          buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(newClassDeserializeFunction(classType)),
            });
        }
      case TEnum(_.get() => enumType, _):
        var methodName = deserializeMethodName(enumType.pack, enumType.name);
        if (deserializingTypes.get(methodName) == null)
        {
          deserializingTypes.set(methodName, enumType);
          buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(newEnumDeserializeFunction(enumType)),
            });
        }
      case TAbstract(_.get() => abstractType, _):
        var methodName = deserializeMethodName(abstractType.pack, abstractType.name);
        if (deserializingTypes.get(methodName) == null)
        {
          deserializingTypes.set(methodName, abstractType);
          buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(newAbstractDeserializeFunction(abstractType)),
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
      var pluginDeserializeField = TypeTools.findField(localUsing.get(), "pluginAsynchronousDeserialize", true);
      if (pluginDeserializeField != null && !pluginDeserializeField.meta.has(":noDynamicAsynchronousDeserialize"))
      {
        var expr = macro $moduleExpr.$nameField.pluginDeserialize(new com.qifun.jsonStream.JsonBuilderFactory.JsonBuilderPluginStream(valueStream), macro onComplete);
        var temporaryFunction = macro function (valueStream:com.qifun.jsonStream.JsonBuilder.AsynchronousJsonStream, onComplete:Dynamic->Void):Void $expr;
        var typedTemporaryFunction = Context.typeExpr(temporaryFunction);
        var resolvedTemporaryFunction = Context.getTypedExpr(typedTemporaryFunction);
        var fullName = switch (Context.follow(typedTemporaryFunction.t))
        {
          case TFun(_, Context.follow(_) => TInst(_.get() => { module: module, name: name }, _)): getFullName(module, name);
          case TFun(_, Context.follow(_) => TAbstract(_.get() => { module: module, name: name }, _)): getFullName(module, name);
          case TFun(_, Context.follow(_) => TEnum(_.get() => { module: module, name: name }, _)): getFullName(module, name);
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
    // trace(ExprTools.toString(switchExpr));

    buildingFields.push(
      {
        name: "dynamicAsynchronousDeserialize",
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
                  [ TPath( { pack: [], name: "Dynamic", } ) ],
                  TPath( { pack: [], name: "Void", } )
                )
              }
            ],
            ret: TPath( { pack: [], name: "Void", } ),
            expr: macro $switchExpr,
          }),
      });
    allBuilders.remove(id);
    buildingFields;
  }

}
#end

enum JsonBuilderError
{
  TOO_MANY_FIELDS<Handler>(read:Handler->Void, expected:Int);
  NOT_ENOUGH_FIELDS<Handler>(read:Handler->Void, expected:Int, actual:Int);
  UNMATCHED_JSON_TYPE(stream:AsynchronousJsonStream, expected: Array<String>);
}


@:dox(hide)
@:final
class JsonBuilderRuntime
{
  
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