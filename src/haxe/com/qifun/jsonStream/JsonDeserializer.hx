package com.qifun.jsonStream;

import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.unknown.UnknownFieldMap;
import com.qifun.jsonStream.unknown.UnknownType;
import haxe.Int64;

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
#end

using Lambda;
using StringTools;

/**
  提供反序列化相关的静态函数，把`JsonStream`反序列化为内存中的各类型数据结构。

  用法：
  <pre>`// MyDeserializer.hx
using com.qifun.jsonStream.Plugins;
@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer([ "myPackage.Module1", "myPackage.Module2", "myPackage.Module3" ]))
class MyDeserializer {}`</pre>

  <pre>`// Sample.hx
using com.qifun.jsonStream.Plugins;
using MyDeserializer;
class Sample
{
  public static function testDeserialize(jsonStream:com.qifun.jsonStream.JsonStream)
  {
    var myClass:myPackage.Module1.MyClass = JsonDeserializer.deserialize(jsonStream);
    // ...
  }
}`</pre>
**/
class JsonDeserializer
{

  /**
    不使用插件，强制把`stream`反序列化为弱类型的JSON对象。
  **/
  @:noUsing
  public static function deserializeRaw(stream:JsonStream):Null<RawJson> return
  {
    new RawJson(switch (stream)
    {
      case JsonStream.OBJECT(entries):
        var object = { };
        for (entry in entries)
        {
          Reflect.setField(object, entry.key, deserializeRaw(entry.value));
        }
        object;
      case JsonStream.STRING(value):
        value;
      case JsonStream.ARRAY(elements):
        [ for (element in elements) deserializeRaw(element) ];
      case JsonStream.NUMBER(value):
        value;
      case JsonStream.TRUE:
        true;
      case JsonStream.FALSE:
        false;
      case JsonStream.NULL:
        null;
      case JsonStream.INT32(value):
        value;
      case JsonStream.INT64(high, low):
        Int64.make(high, low);
    });
  }

  /**
    创建反序列化的实现类。必须用在`@:build`中。

    注意：如果`includeModules`中的某个类没有构造函数，或者构造函数不支持空参数，那么这个类不会被反序列化。

    @param includeModules 类型为`Array<String>`，数组的每一项是一个模块名。在这些模块中应当定义要反序列化的数据结构。
  **/
  @:noUsing
  macro public static function generateDeserializer(includeModules:Array<String>):Array<Field> return
  {
    var generator = new JsonDeserializerGenerator(Context.getLocalClass().get(), Context.getBuildFields());
    for (moduleName in includeModules)
    {
      for (rootType in Context.getModule(moduleName))
      {
        generator.tryAddDeserializeMethod(rootType);
      }
    }
    generator.buildFields();
  }

  /**
    把`stream`反序列化为`Result`类型。

    注意：`deserialize`是宏。会根据`Result`的类型，把具体的反序列化操作转发给当前模块中已经`using`的某个类执行。
    <ul>
      <li>如果`Result`是基本类型，执行序列化的类可能是`deserializerPlugin`包中的内置插件。</li>
      <li>如果`Result`不是基本类型，执行序列化的类需要用`@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer([ ... ]))`创建。</li>
    </ul>
  **/
  @:noUsing
  macro public static function deserialize<Result>(stream:ExprOf<JsonStream>):ExprOf<Null<Result>> return
  {
    var expectedComplexType = TypeTools.toComplexType(Context.getExpectedType());
    if (expectedComplexType == null)
    {
      Context.error("Require explicit return type!", Context.currentPos());
    }
    var typedJsonStreamTypePath =
    {
      pack: [ "com", "qifun", "jsonStream" ],
      name: "JsonDeserializer",
      sub: "JsonDeserializerPluginStream",
      params: [ TPType(expectedComplexType) ],
    };
    var typedJsonStream =
    {
      pos: Context.currentPos(),
      expr: ENew(typedJsonStreamTypePath, [ stream ]),
    };
    macro ($typedJsonStream.pluginDeserialize():$expectedComplexType);
  }

}

/**
  调用`JsonDeserializer.deserialize`时可能抛出的异常。
**/
enum JsonDeserializerError
{
  TOO_MANY_FIELDS<Element>(iterator:Iterator<Element>, expected:Int);
  NOT_ENOUGH_FIELDS<Element>(iterator:Iterator<Element>, expected:Int, actual:Int);
  UNMATCHED_JSON_TYPE(stream:JsonStream, expected: Array<String>);
}

#if macro
@:final
class JsonDeserializerGenerator
{

  private var buildingFields:Array<Field>;

  private var deserializingTypes(default, null) = new StringMap<BaseType>();

  private static var allBuilders = new StringMap<JsonDeserializerGenerator>();

  public function buildFields():Array<Field> return
  {
    var meta = buildingClass.meta;

    meta.add(
      ":access",
      [ macro com.qifun.jsonStream.JsonDeserializerRuntime ],
      Context.currentPos());

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
      var pluginDeserializeField = TypeTools.findField(localUsing.get(), "pluginDeserialize", true);
      if (pluginDeserializeField != null && !pluginDeserializeField.meta.has(":noDynamicDeserialize"))
      {
        var expr = macro $moduleExpr.$nameField.pluginDeserialize(new com.qifun.jsonStream.JsonDeserializer.JsonDeserializerPluginStream(valueStream));
        var temporaryFunction = macro function (valueStream:com.qifun.jsonStream.JsonStream) return $expr;
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
          expr: macro ($resolvedTemporaryFunction(valueStream):Dynamic),
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
          expr: macro ($i{methodName}(valueStream):Dynamic),
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
        name: "dynamicDeserialize",
        pos: Context.currentPos(),
        meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
        access: [ APublic, AStatic ],
        kind: FFun(extractFunction(macro function(dynamicTypeName:String, valueStream:com.qifun.jsonStream.JsonStream):Dynamic return $switchExpr)),
      });
    allBuilders.remove(id);
    buildingFields;
  }

  private var buildingClass:ClassType;

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

  private static function getContextBuilder():JsonDeserializerGenerator return
  {
    var localClass = Context.getLocalClass().get();
    allBuilders.get(localClass.module + "." + localClass.name);
  }

  private static function processName(sb:StringBuf, s:String):Void
  {
    var i = 0;
    while (true)
    {
      var prev = i;
      var found = s.indexOf("_", prev);
      if (found != -1)
      {
        sb.addSub(s, prev, i - prev);
        sb.add("__");
        i = found + 1;
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
    sb.add("deserialize_");
    for (p in pack)
    {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }

  private static function extractFunction(e:ExprOf<JsonStream->Dynamic>):Function return
  {
    switch (e)
    {
      case { expr: EFunction(null, f) }: f;
      case _: throw "Expect Function";
    }
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
                  var parameterValue = resolvedDeserialize(TypeTools.toComplexType(arg.t), macro parameterPair.value, enumAndValueParams);
                  var f =
                  {
                    pos: Context.currentPos(),
                    expr: EFunction(
                      "inline_temporaryEnumDeserialize",
                      {
                        params: valueParams,
                        ret: null,
                        args: [],
                        expr: macro return $parameterValue,
                      })
                  };
                  parameterCases.push(
                    {
                      values: [ Context.makeExpr(arg.name, Context.currentPos()) ],
                      expr: macro
                      {
                        $f;
                        inline function nullize<T>(t:T):Null<T> return t;
                        $i{parameterName} = nullize(temporaryEnumDeserialize());
                      }
                    });
                }
              }
              var switchKey =
              {
                pos: Context.currentPos(),
                expr: ESwitch(
                  macro parameterPair.key,
                  parameterCases,
                  if (unknownFieldMapName == null)
                  {
                    expr: EBlock([]),
                    pos: Context.currentPos(),
                  }
                  else
                  {
                    macro $i{unknownFieldMapName}.underlying.set(parameterPair.key, com.qifun.jsonStream.JsonDeserializer.deserializeRaw(parameterPair.value));
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
                      macro $i{parameterName};
                    }
                  ]),
              };
              block.push(
                macro
                {
                  var generator = com.qifun.jsonStream.JsonDeserializer.JsonDeserializerRuntime.asGenerator(parameterPairs);
                  if (generator != null)
                  {
                    for (parameterPair in generator)
                    {
                      $switchKey;
                    }
                  }
                  else
                  {
                    for (parameterPair in parameterPairs)
                    {
                      $switchKey;
                    }
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
                  switch (pair.value)
                  {
                    case com.qifun.jsonStream.JsonStream.OBJECT(parameterPairs):
                      $blockExpr;
                    case _:
                      throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.UNMATCHED_JSON_TYPE(pair.value, [ "OBJECT" ]);
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
        macro pair.key,
        cases,
        if (unknownEnumValueConstructor == null)
        {
          macro null;
        }
        else
        {
          macro $enumFieldExpr.UNKNOWN_ENUM_VALUE(com.qifun.jsonStream.unknown.UnknownEnumValue.UNKNOWN_PARAMETERIZED_CONSTRUCTOR(
            pair.key,
            com.qifun.jsonStream.JsonDeserializer.deserializeRaw(pair.value)));
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
          macro $enumFieldExpr.UNKNOWN_ENUM_VALUE(com.qifun.jsonStream.unknown.UnknownEnumValue.UNKNOWN_CONSTANT_CONSTRUCTOR(constructorName));
        }),
    }
    var methodBody = macro switch (stream)
    {
      case STRING(constructorName):
        $zeroParameterBranch;
      case OBJECT(pairs):
        function selectEnumValue(pair:com.qifun.jsonStream.JsonStream.JsonStreamPair) return $processObjectBody;
        com.qifun.jsonStream.JsonDeserializer.JsonDeserializerRuntime.optimizedExtract1(
          pairs,
          selectEnumValue);
      case NULL:
        null;
      case _:
        throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "STRING", "OBJECT", "NULL" ]);
    }

    var expectedTypePath =
    {
      pack: enumType.pack,
      name: enumType.module.substring(enumType.module.lastIndexOf(".") + 1),
      sub: enumType.name,
      params: [ for (p in enumType.params) TPType(TPath({ pack: [], name: p.name})) ]
    };
    {
      args:
      [
        {
          name:"stream",
          type: MacroStringTools.toComplex("com.qifun.jsonStream.JsonStream"),
        },
      ],
      ret: TPath(expectedTypePath),
      expr: macro return $methodBody,
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
    {
      args:
      [
        {
          name:"stream",
          type: MacroStringTools.toComplex("com.qifun.jsonStream.JsonStream"),
        },
      ],
      ret: TPath(expectedTypePath),
      expr: macro return cast $implExpr,
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
            type:
              Context.follow(_) =>
              TAbstract(
                _.get() =>
                {
                  module: "com.qifun.jsonStream.unknown.UnknownFieldMap",
                  name: "UnknownFieldMap"
                },
                []),
          }:
            hasUnknownFieldMap = true;
          case
          {
            kind: FVar(AccNormal | AccNo, AccNormal | AccNo),
            meta: meta,
            type:
              Context.follow(_) =>
              TInst(
                _.get() =>
                {
                  module: "haxe.Int64",
                  name: "Int64"
                },
                [])
              } if (!meta.has(":transient")):
          {
            // Workaround for https://github.com/HaxeFoundation/haxe/issues/3203
            var fieldName = field.name;
            var d = resolvedDeserialize(TypeTools.toComplexType(applyTypeParameters(field.type)), macro pair.value, params);
            cases.push(
              {
                values: [ macro $v{fieldName} ],
                guard: null,
                expr: macro result.$fieldName = com.qifun.jsonStream.JsonDeserializer.JsonDeserializerRuntime.toInt64($d),
              });
          }
          case { kind: FVar(AccNormal | AccNo, AccNormal | AccNo), meta: meta } if (!meta.has(":transient")):
          {
            var fieldName = field.name;
            var d = resolvedDeserialize(TypeTools.toComplexType(applyTypeParameters(field.type)), macro pair.value, params);
            cases.push(
              {
                values: [ macro $v{fieldName} ],
                guard: null,
                expr: macro result.$fieldName = $d,
              });
          }
          case _:
          {
            continue;
          }
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
      expr: ESwitch(macro pair.key, cases,
        if (hasUnknownFieldMap)
        {
          macro result.unknownFieldMap.underlying.set(pair.key, com.qifun.jsonStream.JsonDeserializer.deserializeRaw(pair.value));
        }
        else
        {
          macro null;
        }),
    }

    var switchStream = macro switch (stream)
    {
      case OBJECT(pairs):
        var result = $newInstance;
        var generator = com.qifun.jsonStream.JsonDeserializer.JsonDeserializerRuntime.asGenerator(pairs);
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
        throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "OBJECT" ]);
    }

    // trace(ExprTools.toString(switchStream));

    {
      args:
      [
        {
          name:"stream",
          type: MacroStringTools.toComplex("com.qifun.jsonStream.JsonStream"),
        },
      ],
      ret: TPath(expectedTypePath),
      expr: macro return $switchStream,
      params: params,
    }
  }

  public function tryAddDeserializeMethod(type:Type):Void
  {
    switch (Context.follow(type))
    {
      case TInst(_.get() => classType, _) if (!isAbstract(classType)):
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

  @:noUsing
  public static function dynamicDeserialize(stream:ExprOf<JsonStream>, expectedType:Type):Expr return
  {
    var expectedComplexType = TypeTools.toComplexType(Context.follow(expectedType));
    var localUsings = Context.getLocalUsing();
    function createFunction(i:Int, key:ExprOf<String>, value:ExprOf<JsonStream>):Expr return
    {
      if (i < localUsings.length)
      {
        var classType = localUsings[i].get();
        var field = TypeTools.findField(classType, "dynamicDeserialize", true);
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
            var result = $modulePath.$className.dynamicDeserialize($key, $value);
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
            macro (new com.qifun.jsonStream.unknown.UnknownType($key, com.qifun.jsonStream.JsonDeserializer.deserializeRaw($value)):Dynamic);
          }
          else if (
            Context.unify(expectedType, hasUnknownTypeFieldType) ||
            Context.unify(expectedType, hasUnknownTypeSetterType))
          {
            macro
            {
              var result = new $typePath();
              result.unknownType = new com.qifun.jsonStream.unknown.UnknownType($key, com.qifun.jsonStream.JsonDeserializer.deserializeRaw($value));
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
            var knownValue = untyped($modulePath.$className).dynamicDeserialize($key, $value);
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
    var processDynamic = createFunction(0, macro dynamicPair.key, macro dynamicPair.value);
    macro (function(stream:com.qifun.jsonStream.JsonStream):Dynamic return
    {
      switch (stream)
      {
        case OBJECT(pairs):
          com.qifun.jsonStream.JsonDeserializer.JsonDeserializerRuntime.optimizedExtract1(
            pairs,
            function(dynamicPair) return $processDynamic);
        case NULL:
          null;
        case _:
          throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializerError.UNMATCHED_JSON_TYPE(stream, [ "OBJECT", "NULL" ]);
      }
    })($stream);
  }

  private var buildingClassExpr(get, never):Expr;

  private function get_buildingClassExpr():Expr return
  {
    var modulePath = MacroStringTools.toFieldExpr(buildingClass.module.split("."));
    var className = buildingClass.name;
    macro $modulePath.$className;
  }

  @:noUsing
  public static function generatedDeserialize(expectedType:Type, stream:ExprOf<JsonStream>):Expr return
  {
    switch (Context.follow(expectedType))
    {
      case TInst(_.get() => classType, _) if (!isAbstract(classType)):
        var methodName = deserializeMethodName(classType.pack, classType.name);
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
              return macro $pathExpr.$methodName($stream);
            }
            else
            {
              return dynamicDeserialize(stream, expectedType);
            }
          }
        }
        var contextBuilder = getContextBuilder();
        if (contextBuilder == null)
        {
          Context.error(
            'No plugin or deserializer for ${
              TypeTools.toString(expectedType)
            }.', Context.currentPos());
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
              kind: FFun(contextBuilder.newClassDeserializeFunction(classType)),
            });
        }
        if (classType.meta.has(":final"))
        {
          var buildingClassExpr = contextBuilder.buildingClassExpr;
          macro untyped($buildingClassExpr).$methodName($stream);
        }
        else
        {
          dynamicDeserialize(stream, expectedType);
        }
      case TEnum(_.get() => enumType, _):
        var methodName = deserializeMethodName(enumType.pack, enumType.name);
        for (usingClassRef in Context.getLocalUsing())
        {
          var usingClass = usingClassRef.get();
          var field = TypeTools.findField(usingClass, methodName, true);
          if (field != null)
          {
            var path = usingClass.module.split(".");
            path.push(usingClass.name);
            var pathExpr = MacroStringTools.toFieldExpr(path);
            return macro $pathExpr.$methodName($stream);
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
              kind: FFun(contextBuilder.newEnumDeserializeFunction(enumType)),
            });
        }
        var buildingClassExpr = contextBuilder.buildingClassExpr;
        macro untyped($buildingClassExpr).$methodName($stream);
      case TAbstract(_.get() => abstractType, _):
        var methodName = deserializeMethodName(abstractType.pack, abstractType.name);
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
              return macro $pathExpr.$methodName($stream);
            }
            else
            {
              return dynamicDeserialize(stream, expectedType);
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
              kind: FFun(contextBuilder.newAbstractDeserializeFunction(abstractType)),
            });
        }
        if (abstractType.impl.get().meta.has(":final"))
        {
          var buildingClassExpr = contextBuilder.buildingClassExpr;
          macro untyped($buildingClassExpr).$methodName($stream);
        }
        else
        {
          dynamicDeserialize(stream, expectedType);
        }
      case t:
        dynamicDeserialize(stream, expectedType);
    }
  }

  /**
    类似`deserialize`，但是能递归解决类型，以便能够在`@:build`宏返回以前就立即执行。
  **/
  @:noUsing
  public static function resolvedDeserialize(expectedComplexType:ComplexType, stream:ExprOf<JsonStream>, ?params:Array<TypeParamDecl>):Expr return
  {
    var typedJsonStreamTypePath =
    {
      pack: [ "com", "qifun", "jsonStream" ],
      name: "JsonDeserializer",
      sub: "JsonDeserializerPluginStream",
      params: [ TPType(expectedComplexType) ],
    };
    var typedJsonStreamType = TPath(typedJsonStreamTypePath);
    var f =
    {
      expr:
        EFunction("temporaryDeserialize",
        {
          args: [ { name: "typedJsonStream", type: typedJsonStreamType } ],
          ret: expectedComplexType,
          expr: macro return typedJsonStream.pluginDeserialize(),
          params: params,
        }),
      pos: Context.currentPos()
    }
    var placeholderExpr = macro
    {
      // 提供一个假的currentJsonDeserializerSet，以避免编译错误，然后后续处理时，再替换掉它
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
          temporaryDeserialize($typedJsonStream);
        }
      case t:
        throw "Expect EBlock, actual " + ExprTools.toString(t);
    };
  }


}

#end

/**
  实现反序列化插件时使用的内部类型，包装了一个`JsonStream`。
**/
@:dox(hide)
abstract JsonDeserializerPluginStream<ResultType>(JsonStream)
{

  @:extern
  public inline function new(underlying:JsonStream)
  {
    this = underlying;
  }

  public var underlying(get, never):JsonStream;

  @:extern
  inline function get_underlying():JsonStream return
  {
    this;
  }

}

@:dox(hide)
@:final
class JsonDeserializerRuntime
{

  @:noUsing
  #if (!java) inline #end
  public static function toInt64(d:Dynamic):Int64 return
  {
    #if java
    untyped __java__("(long)d"); // Workaround for https://github.com/HaxeFoundation/haxe/issues/3203
    #else
    d;
    #end
  }

  @:generic
  //@:extern
  @:noUsing
  private static inline function newInstanceForStream<T:{ function new():Void; }>(stream:JsonDeserializerPluginStream<T>):T return
  {
    new T();
  }

  @:extern
  @:noUsing
  private static inline function asGenerator<Element>(iterator:Iterator<Element>):Null<Generator<Element>> return
  {
    Std.instance(iterator, (Generator:Class<Generator<Element>>));
  }

  @:extern
  @:noUsing
  private static inline function extract1<Element, Result>(iterator:Iterator<Element>, handler:Element->Result):Result return
  {
    if (iterator.hasNext())
    {
      var element = iterator.next();
      if (iterator.hasNext())
      {
        throw TOO_MANY_FIELDS(iterator, 1);
      }
      else
      {
        handler(element);
      }
    }
    else
    {
      throw NOT_ENOUGH_FIELDS(iterator, 1, 0);
    }
  }

  @:extern
  @:noUsing
  public static inline function optimizedExtract1<Element, Result>(iterator:Iterator<Element>, handler:Element->Result):Result return
  {
    var generator = Std.instance(iterator, (Generator:Class<Generator<Element>>));
    if (generator == null)
    {
      extract1(iterator, handler);
    }
    else
    {
      extract1(generator, handler);
    }
  }
}
