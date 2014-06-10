package com.qifun.jsonStream;
import com.dongxiguo.continuation.utils.Generator;
import com.dongxiguo.continuation.Continuation;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.unknown.UnknownEnumValue;
import com.qifun.jsonStream.unknown.UnknownFieldMap;
import com.qifun.jsonStream.unknown.UnknownType;
import Type in StdType;
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

using StringTools;

/**
  提供序列化相关的静态函数，把内存中的各类型数据结构序列化为`JsonStream`。

  用法：
  <pre>`// MySerializer.hx
using com.qifun.jsonStream.Plugins;
@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer([ "myPackage.Module1", "myPackage.Module2", "myPackage.Module3" ]))
class MySerializer {}`</pre>

  <pre>`// Sample.hx
using com.qifun.jsonStream.Plugins;
using MySerializer;
class Sample
{
  public static function testSerialize(data:myPackage.Module1.MyClass)
  {
    var jsonStream:JsonStream = JsonDeserializer.serialize(data);
    // ...
  }
}`</pre>
**/
@:final
class JsonSerializer
{

  private static function iterateJsonObject(instance:Dynamic) return
  {
    new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStreamPair>):Void
    {
      for (field in Reflect.fields(instance))
      {
        yield(new JsonStream.JsonStreamPair(field, serializeRaw(Reflect.field(instance, field)))).async();
      }
    }));
  }

  private static function iterateJsonArray(instance:Array<RawJson>) return
  {
    new Generator(Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
    {
      for (element in instance)
      {
        yield(serializeRaw(element)).async();
      }
    }));
  }

  /**
    Returns a stream that reads data from `rawJson`.
  **/
  @:noUsing
  public static function serializeRaw(rawJson:RawJson):JsonStream return
  {
    switch (StdType.typeof(rawJson.underlying))
    {
      case TObject:
        JsonStream.OBJECT(iterateJsonObject(rawJson.underlying));
      case TClass(String):
        JsonStream.STRING(rawJson.underlying);
      case TClass(Array):
        JsonStream.ARRAY(iterateJsonArray(rawJson.underlying));
      case TInt:
        JsonStream.NUMBER(rawJson.underlying);
      case TFloat:
        JsonStream.NUMBER(rawJson.underlying);
      case TBool if (rawJson.underlying):
        JsonStream.TRUE;
      case TBool if (!rawJson.underlying):
        JsonStream.FALSE;
      case TNull:
        JsonStream.NULL;
      case t:
        throw 'Unsupported rawJson data: $t';
    }
  }


  /**
    创建序列化的实现类。必须用在`@:build`中。

    @param includeModules 类型为`Array<String>`，数组的每一项是一个模块名。在这些模块中应当定义要序列化的数据结构。
  **/
  @:noUsing
  macro public static function generateSerializer(includeModules:Array<String>):Array<Field> return
  {
    var generator = new JsonSerializerGenerator(Context.getLocalClass().get(), Context.getBuildFields());
    for (moduleName in includeModules)
    {
      for (rootType in Context.getModule(moduleName))
      {
        generator.tryAddSerializeMethod(rootType);
      }
    }
    generator.buildFields();
  }

  /**
    把`data`序列化为`JsonStream`.

    注意：`serialize`是宏，会根据`data`的类型，把具体的序列化操作转发给当前模块中已经`using`的某个类执行。
    <ul>
      <li>如果`data`是基本类型，执行序列化的类可能是`serializerPlugin`包中的内置插件。</li>
      <li>如果`data`不是基本类型，执行序列化的类需要用`@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer([ ... ]))`创建。</li>
    </ul>
  **/
  macro public static function serialize(data:Expr):ExprOf<JsonStream> return
  {
    macro new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData(
      $data).pluginSerialize();
  }

}

@:dox(hide)
abstract JsonSerializerPluginData<Data>(Null<Data>)
{

  @:extern
  public inline function new(underlying:Null<Data>)
  {
    this = underlying;
  }

  public var underlying(get, never):Null<Data>;

  @:extern
  inline function get_underlying():Null<Data> return
  {
    this;
  }

}

#if macro
class JsonSerializerGenerator
{

  private var buildingFields:Array<Field>;

  private var serializingTypes(default, null) = new StringMap<Type>();

  private static function toBaseType(type:Type):BaseType return
  {
    switch (type)
    {
      case TEnum(t, _): t.get();
      case TInst(t, _): t.get();
      case TAbstract(t, _): t.get();
      case t: throw 'Unsupported type $t';
    }
  }

  private static var allBuilders = new StringMap<JsonSerializerGenerator>();

  public function buildFields():Array<Field> return
  {
    var meta = buildingClass.meta;

    meta.add(
      ":access",
      [ macro com.qifun.jsonStream.JsonSerializerRuntime ],
      Context.currentPos());

    for (serializingType in serializingTypes)
    {
      var baseType = toBaseType(serializingType);
      var accessPack = MacroStringTools.toFieldExpr(baseType.pack);
      var accessName = baseType.name;
      meta.add(
        ":access",
        [ accessPack == null ? macro $i{accessName} : macro $accessPack.$accessName ],
        Context.currentPos());
    }

    var dynamicCases:Array<Case> = [];

    function newCase(dataType:Type, valueExpr:Expr):Null<Case> return
    {
      switch (dataType)
      {
        case TInst(_.get() => { module: "haxe.Int64", name: "Int64" }, _):
          var pattern = macro _;
          var guard = macro Std.is(data, haxe.Int64);
          var fullName = "haxe.Int64";
          { values: [ pattern ], guard: guard, expr: macro new com.qifun.jsonStream.JsonStream.JsonStreamPair($v{fullName}, $valueExpr), };
        case TInst(_.get() => { module: module, name: name }, _):
          var moduleExpr = MacroStringTools.toFieldExpr(module.split("."));
          var pattern = macro Type.ValueType.TClass($moduleExpr.$name);
          var fullName = getFullName(module, name);
          { values: [ pattern ], expr: macro new com.qifun.jsonStream.JsonStream.JsonStreamPair($v{fullName}, $valueExpr), };
        case TEnum(_.get() => { module: module, name: name }, _):
          var moduleExpr = MacroStringTools.toFieldExpr(module.split("."));
          var pattern = macro Type.ValueType.TEnum($moduleExpr.$name);
          var fullName = getFullName(module, name);
          { values: [ pattern ], expr: macro new com.qifun.jsonStream.JsonStream.JsonStreamPair($v{fullName}, $valueExpr), };
        case TAbstract(_.get() => { module: "StdTypes", name: "Float" }, _):
          var pattern = macro Type.ValueType.TFloat;
          var fullName = "Float";
          { values: [ pattern ], expr: macro new com.qifun.jsonStream.JsonStream.JsonStreamPair($v{fullName}, $valueExpr), };
        case TAbstract(_.get() => { module: "StdTypes", name: "Single" }, _):
          var pattern = macro Type.ValueType.TFloat;
          var fullName = "Single";
          { values: [ pattern ], expr: macro new com.qifun.jsonStream.JsonStream.JsonStreamPair($v{fullName}, $valueExpr), };
        case TAbstract(_.get() => { module: "StdTypes", name: "Bool" }, _):
          var pattern = macro Type.ValueType.TBool;
          var fullName = "Bool";
          { values: [ pattern ], expr: macro new com.qifun.jsonStream.JsonStream.JsonStreamPair($v{fullName}, $valueExpr), };
        case TAbstract(_.get() => { module: "StdTypes", name: "Int" }, _):
          var pattern = macro Type.ValueType.TInt;
          var fullName = "Int";
          { values: [ pattern ], expr: macro new com.qifun.jsonStream.JsonStream.JsonStreamPair($v{fullName}, $valueExpr), };
        case TAbstract(_.get() => { module: "UInt", name: "UInt" }, _):
          var pattern = macro Type.ValueType.TInt;
          var fullName = "UInt";
          { values: [ pattern ], expr: macro new com.qifun.jsonStream.JsonStream.JsonStreamPair($v{fullName}, $valueExpr), };
        case TAbstract(_.get() => { type: impType }, _):
          null;
        case t:
          null;
      }
    }
    for (localUsing in Context.getLocalUsing())
    {
      var baseType:BaseType = switch (localUsing.get())
      {
        case { kind: KAbstractImpl(a) } : a.get();
        case classType: classType;
      }
      var moduleExpr = MacroStringTools.toFieldExpr(baseType.module.split("."));
      var nameField = baseType.name;
      var pluginSerializeField = TypeTools.findField(localUsing.get(), "pluginSerialize", true);
      if (pluginSerializeField != null && !pluginSerializeField.meta.has(":noDynamicSerialize"))
      {
        var expr = macro $moduleExpr.$nameField.pluginSerialize(data);
        var temporaryFunction = macro function (data) return $expr;
        var typedTemporaryFunction = Context.typeExpr(temporaryFunction);
        var resolvedTemporaryFunction = Context.getTypedExpr(typedTemporaryFunction);
        switch (Context.follow(typedTemporaryFunction.t))
        {
          case TFun([ { t: TAbstract(_, [dataType]) } ], _):
            var c = newCase(
              dataType,
              macro $resolvedTemporaryFunction(data));
            if (c != null)
            {
              dynamicCases.push(c);
            }
          default: continue;
        }
      }
    }

    for (methodName in serializingTypes.keys())
    {
      var c = newCase(serializingTypes.get(methodName), macro $i{methodName}(data));
      if (c != null)
      {
        dynamicCases.push(c);
      }
    }

    var switchExpr =
    {
      pos: Context.currentPos(),
      expr: ESwitch(macro valueType, dynamicCases, macro null),
    }
    // trace(ExprTools.toString(switchExpr));

    buildingFields.push(
      {
        name: "dynamicSerialize",
        pos: Context.currentPos(),
        meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
        access: [ APublic, AStatic ],
        kind: FFun(extractFunction(macro function(valueType:Type.ValueType, data:Dynamic):Null<com.qifun.jsonStream.JsonStream.JsonStreamPair> return $switchExpr)),
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

  private static function getContextBuilder():JsonSerializerGenerator return
  {
    var localClass = Context.getLocalClass().get();
    allBuilders.get(localClass.module + "." + localClass.name);
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

  private static function serializeMethodName(pack:Array<String>, name:String):String
  {
    var sb = new StringBuf();
    sb.add("serialize_");
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

  private function newEnumSerializeFunction(enumType:EnumType):Function return
  {
    var enumParams: Array<TypeParamDecl> =
    [
      for (tp in enumType.params)
      {
        name: tp.name,
        // TODO: constraits
      }
    ];
    var cases:Array<Case> =
    [
      {
        values: [ macro null ],
        expr: macro com.qifun.jsonStream.JsonStream.NULL,
      }
    ];
    var unknownEnumValueConstructor = null;
    for (constructor in enumType.constructs)
    {
      switch (constructor)
      {
        case { name: "UNKNOWN_ENUM_VALUE", type: TFun([ { t: TEnum(_.get() => { module: "com.qifun.jsonStream.unknown.UnknownEnumValue", name: "UnknownEnumValue" }, _) } ], _) }:
        {
          cases.push(
            {
              values: [ macro UNKNOWN_ENUM_VALUE(v) ],
              expr: macro com.qifun.jsonStream.JsonSerializer.JsonSerializerRuntime.serializeUnknwonEnumValue(v),
            });
        }
        case { type: TFun(args, _) } :
          var parameterExprs = [];
          var blockExprs = [];
          var valueParams: Array<TypeParamDecl> =
          [
            for (tp in constructor.params)
            {
              name: tp.name,
              // TODO: constraits
            }
          ];
          var enumAndValueParams = enumParams.concat(valueParams);
          for (i in 0...args.length)
          {
            var parameterName = 'constructorParameter$i';
            var parameterExpr = macro $i{parameterName};
            parameterExprs.push(parameterExpr);
            switch (args[i])
            {
              case {
                name: "unknownFieldMap",
                t: Context.follow(_) => TAbstract(_.get() => { module: "com.qifun.jsonStream.unknown.UnknownFieldMap", name: "UnknownFieldMap" }, []),
              }:
                blockExprs.push(macro com.qifun.jsonStream.JsonSerializer.JsonSerializerRuntime.yieldUnknownFieldMap($parameterExpr, yield).async());
              case { name: parameterKey, t: parameterType, }:
                var s = resolvedSerialize(TypeTools.toComplexType(parameterType), macro parameterData, enumAndValueParams);
                // trace(ExprTools.toString(s));
                var f =
                  {
                    pos: Context.currentPos(),
                    expr: EFunction(
                      #if no_inline
                        "temporaryEnumValueSerialize"
                      #else
                        "inline_temporaryEnumValueSerialize"
                      #end,
                      {
                        params: enumAndValueParams,
                        ret: null,
                        args: [ { name: "parameterData", type: null, } ],
                        expr: macro return $s,
                      })
                  };
                blockExprs.push(
                  macro if (com.qifun.jsonStream.JsonSerializer.JsonSerializerRuntime.isNotNull($parameterExpr))
                  {
                    $f;
                    yield(new com.qifun.jsonStream.JsonStream.JsonStreamPair($v{parameterKey}, temporaryEnumValueSerialize(com.qifun.jsonStream.JsonSerializer.JsonSerializerRuntime.nullize($parameterExpr)))).async();
                  });
            }
          }
          var block =
          {
            expr: EBlock(blockExprs),
            pos: Context.currentPos(),
          }
          var constructorName = constructor.name;
          cases.push(
            {
              values: [ macro $i{constructorName}($a{parameterExprs}) ],
              expr: macro com.qifun.jsonStream.JsonStream.OBJECT(
                new com.dongxiguo.continuation.utils.Generator(
                  com.dongxiguo.continuation.Continuation.cpsFunction(
                    function(yield:com.dongxiguo.continuation.utils.Generator.YieldFunction<com.qifun.jsonStream.JsonStream.JsonStreamPair>):Void
                      yield(
                        new com.qifun.jsonStream.JsonStream.JsonStreamPair(
                          $v{constructorName},
                          com.qifun.jsonStream.JsonStream.OBJECT(
                            new com.dongxiguo.continuation.utils.Generator(
                              com.dongxiguo.continuation.Continuation.cpsFunction(
                                function(yield:com.dongxiguo.continuation.utils.Generator.YieldFunction<com.qifun.jsonStream.JsonStream.JsonStreamPair>):Void $block))))).async()))),
            });
        case { name: constructorName } :
          cases.push(
            {
              values: [ macro $i{constructorName} ],
              expr: macro com.qifun.jsonStream.JsonStream.STRING($v{constructorName}),
            });
      }
    }
    var methodBody =
    {
      expr: ESwitch(macro data, cases, null),
      pos: Context.currentPos(),
    };
    var enumModule = enumType.module;
    var enumComplexType =
      TPath(
        {
          pack: enumType.pack,
          name: enumModule.substring(enumModule.lastIndexOf(".")),
          sub: enumType.name,
          params: [ for (tp in enumType.params) TPType(TPath({ name: tp.name, pack: []})) ]
        });
    {
      args:
      [
        {
          name: "data",
          type: TPath(
            {
              pack: [],
              name: "Null",
              params: [ TPType(enumComplexType) ]
            }),
        },
      ],
      ret: null,
      expr: macro return $methodBody,
      params: enumParams,
    }
  }

  private function newAbstractSerializeFunction(abstractType:AbstractType):Function return
  {
    var params: Array<TypeParamDecl> =
    [
      for (tp in abstractType.params)
      {
        name: tp.name,
        // TODO: constraits
      }
    ];
    var implExpr = resolvedSerialize(TypeTools.toComplexType(abstractType.type), macro cast data, params);
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
          name:"data",
          type: TPath(expectedTypePath),
        },
      ],
      ret: null,
      expr: macro return $implExpr,
      params: params,
    }
  }

  private function newClassSerializeFunction(classType:ClassType):Function return
  {
    var params: Array<TypeParamDecl> =
    [
      for (tp in classType.params)
      {
        name: tp.name,
        // TODO: constraits
      }
    ];
    var blockExprs:Array<Expr> = [];
    function addBlockExprs(classType:Null<ClassType>, ?concreteTypes:Array<Type>):Void
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
            blockExprs.push(macro com.qifun.jsonStream.JsonSerializer.JsonSerializerRuntime.yieldUnknownFieldMap(data.unknownFieldMap, yield).async());
          case { kind: FVar(AccNormal | AccNo, AccNormal | AccNo), }:
            var fieldName = field.name;
            var s = resolvedSerialize(TypeTools.toComplexType(applyTypeParameters(field.type)), macro data.$fieldName, params);
            blockExprs.push(
              macro if (com.qifun.jsonStream.JsonSerializer.JsonSerializerRuntime.isNotNull(data.$fieldName))
              {
                yield(new com.qifun.jsonStream.JsonStream.JsonStreamPair($v{fieldName}, $s)).async();
              });
          case _:
            continue;
        }
      }
      var superClass = classType.superClass;
      if (superClass != null)
      {
        addBlockExprs(
          superClass.t.get(),
          [ for (p in superClass.params) applyTypeParameters(p) ]);
      }
    }
    addBlockExprs(classType);
    var block =
    {
      expr: EBlock(blockExprs),
      pos: Context.currentPos(),
    }
    var classModule = classType.module;
    {
      args:
      [
        {
          name:"data",
          type: TPath(
            {
              pack: classType.pack,
              name: classModule.substring(classModule.lastIndexOf(".")),
              sub: classType.name,
              params: [ for (tp in classType.params) TPType(TPath({ name: tp.name, pack: []})) ]
            }),
        },
      ],
      ret: null,
      expr: macro return
        com.qifun.jsonStream.JsonStream.OBJECT(
          new com.dongxiguo.continuation.utils.Generator<com.qifun.jsonStream.JsonStream.JsonStreamPair>(com.dongxiguo.continuation.Continuation.cpsFunction(
            function(yield:com.dongxiguo.continuation.utils.Generator.YieldFunction<com.qifun.jsonStream.JsonStream.JsonStreamPair>):Void $block))),
      params: params,
    }
  }

  public function tryAddSerializeMethod(type:Type):Void
  {
    var followedType = Context.follow(type);
    switch (followedType)
    {
      case TInst(_.get() => classType, _) if (!isAbstract(classType)):
        var methodName = serializeMethodName(classType.pack, classType.name);
        if (serializingTypes.get(methodName) == null)
        {
          serializingTypes.set(methodName, followedType);
          buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(newClassSerializeFunction(classType)),
            });
        }
      case TEnum(_.get() => enumType, _):
        var methodName = serializeMethodName(enumType.pack, enumType.name);
        if (serializingTypes.get(methodName) == null)
        {
          serializingTypes.set(methodName, followedType);
          buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(newEnumSerializeFunction(enumType)),
            });
        }
      case TAbstract(_.get() => abstractType, _):
        var methodName = serializeMethodName(abstractType.pack, abstractType.name);
        if (serializingTypes.get(methodName) == null)
        {
          serializingTypes.set(methodName, followedType);
          buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(newAbstractSerializeFunction(abstractType)),
            });
        }
      case _:
    }
  }

  public static function dynamicSerialize(data:Expr, expectedComplexType:ComplexType):ExprOf<JsonStream> return
  {
    var localUsings = Context.getLocalUsing();
    function createFunction(i:Int, valueType:ExprOf<Type.ValueType>, value:Expr):ExprOf<JsonStreamPair> return
    {
      if (i < localUsings.length)
      {
        var classType = localUsings[i].get();
        var field = TypeTools.findField(classType, "dynamicSerialize", true);
        if (field == null)
        {
          createFunction(i + 1, valueType, value);
        }
        else
        {
          var modulePath = MacroStringTools.toFieldExpr(classType.module.split("."));
          var className = classType.name;
          var next = createFunction(i + 1, valueType, value);
          macro
          {
            var result = $modulePath.$className.dynamicSerialize($valueType, $value);
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
        if (contextBuilder == null)
        {
          macro com.qifun.jsonStream.JsonSerializer.JsonSerializerRuntime.serializeUnknown($value);
        }
        else
        {
          var classType = getContextBuilder().buildingClass;
          var modulePath = MacroStringTools.toFieldExpr(classType.module.split("."));
          var className = classType.name;
          macro
          {
            var knownValue = untyped($modulePath.$className).dynamicSerialize($valueType, $value);
            if (knownValue == null)
            {
              com.qifun.jsonStream.JsonSerializer.JsonSerializerRuntime.serializeUnknown($value);
            }
            else
            {
              knownValue;
            }
          }
        }
      }
    }
    var processDynamic =
      createFunction(0, macro dynamicValueType, macro dynamicData);
    macro (function(dynamicData:Dynamic):com.qifun.jsonStream.JsonStream return
      dynamicData == null ?
      com.qifun.jsonStream.JsonStream.NULL :
      com.qifun.jsonStream.JsonStream.OBJECT(
        new com.dongxiguo.continuation.utils.Generator(
          com.dongxiguo.continuation.Continuation.cpsFunction(
            function(
              yield:com.dongxiguo.continuation.utils.Generator.YieldFunction<
                com.qifun.jsonStream.JsonStream.JsonStreamPair>):Void
            {
              var dynamicValueType = Type.Type.typeof(dynamicData);
              yield($processDynamic).async();
            }))))($data);
  }

  private var buildingClassExpr(get, never):Expr;

  private function get_buildingClassExpr():Expr return
  {
    var modulePath = MacroStringTools.toFieldExpr(buildingClass.module.split("."));
    var className = buildingClass.name;
    macro $modulePath.$className;
  }

  public static function generatedSerialize(data:Expr, expectedType:Type):Expr return
  {
    var followedType = Context.follow(expectedType);
    switch (followedType)
    {
      case TInst(_.get() => classType, _) if (!isAbstract(classType)):
        var methodName = serializeMethodName(classType.pack, classType.name);
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
              return macro $pathExpr.$methodName($data);
            }
            else
            {
              return dynamicSerialize(data, TypeTools.toComplexType(expectedType));
            }
          }
        }
        var contextBuilder = getContextBuilder();
        if (contextBuilder.serializingTypes.get(methodName) == null)
        {
          contextBuilder.serializingTypes.set(methodName, followedType);
          contextBuilder.buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(contextBuilder.newClassSerializeFunction(classType)),
            });
        }
        if (classType.meta.has(":final"))
        {
          var buildingClassExpr = contextBuilder.buildingClassExpr;
          macro untyped($buildingClassExpr).$methodName($data);
        }
        else
        {
          dynamicSerialize(data, TypeTools.toComplexType(expectedType));
        }
      case TEnum(_.get() => enumType, _):
        var methodName = serializeMethodName(enumType.pack, enumType.name);
        for (usingClassRef in Context.getLocalUsing())
        {
          var usingClass = usingClassRef.get();
          var field = TypeTools.findField(usingClass, methodName, true);
          if (field != null)
          {
            var path = usingClass.module.split(".");
            path.push(usingClass.name);
            var pathExpr = MacroStringTools.toFieldExpr(path);
            return macro $pathExpr.$methodName($data);
          }
        }
        var contextBuilder = getContextBuilder();
        if (contextBuilder.serializingTypes.get(methodName) == null)
        {
          contextBuilder.serializingTypes.set(methodName, followedType);
          contextBuilder.buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(contextBuilder.newEnumSerializeFunction(enumType)),
            });
        }
        var buildingClassExpr = contextBuilder.buildingClassExpr;
        macro untyped($buildingClassExpr).$methodName($data);
      case TAbstract(_.get() => abstractType, _):
        var methodName = serializeMethodName(abstractType.pack, abstractType.name);
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
              return macro $pathExpr.$methodName($data);
            }
            else
            {
              return dynamicSerialize(data, TypeTools.toComplexType(expectedType));
            }
          }
        }
        var contextBuilder = getContextBuilder();
        if (contextBuilder.serializingTypes.get(methodName) == null)
        {
          contextBuilder.serializingTypes.set(methodName, followedType);
          contextBuilder.buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
              access: [ APublic, AStatic ],
              kind: FFun(contextBuilder.newAbstractSerializeFunction(abstractType)),
            });
        }
        if (abstractType.impl.get().meta.has(":final"))
        {
          var buildingClassExpr = contextBuilder.buildingClassExpr;
          macro untyped($buildingClassExpr).$methodName($data);
        }
        else
        {
          dynamicSerialize(data, TypeTools.toComplexType(expectedType));
        }
      case t:
        dynamicSerialize(data, TypeTools.toComplexType(expectedType));
    }
  }

  // 类似serialize，但是能递归解决类型，以便能够在@:build宏返回以前就立即执行
  private static function resolvedSerialize(expectedComplexType:ComplexType, data:Expr, ?params:Array<TypeParamDecl>):Expr return
  {
    var typedDataTypePath =
    {
      pack: [ "com", "qifun", "jsonStream" ],
      name: "JsonSerializer",
      sub: "JsonSerializerPluginData",
      params: [ TPType(expectedComplexType) ],
    };
    var typedDataType = TPath(typedDataTypePath);
    var f =
    {
      expr:
        EFunction("temporarySerialize",
        {
          args: [ { name: "typedData", type: typedDataType } ],
          ret: null,
          expr: macro return typedData.pluginSerialize(),
          params: params,
        }),
      pos: Context.currentPos()
    }
    var placeholderExpr = macro
    {
      // 提供一个假的currentJsonSerializerSet，以避免编译错误，然后后续处理时，再替换掉它
      $f;
      null;
    }
    //trace(ExprTools.toString(placeholderExpr));
    //trace(ExprTools.toString(Context.getTypedExpr(Context.typeExpr(placeholderExpr))));
    switch (Context.getTypedExpr(Context.typeExpr(placeholderExpr)))
    {
      case { expr: EBlock([ { expr: EFunction(_, resolved) | EVars([ { expr: {expr: EFunction(null, resolved)}}])}, _ ]) } :
        var typedData =
        {
          pos: Context.currentPos(),
          expr: ENew(typedDataTypePath, [ data ]),
        }
        var f =
        {
          expr: EFunction("inline_temporarySerialize", resolved),
          pos: Context.currentPos(),
        }
        macro
        {
          $f;
          temporarySerialize($typedData);
        }
      case t:
        throw "Expect EBlock, actual " + ExprTools.toString(t);
    };
  }

}
#end

@:dox(hide)
class JsonSerializerRuntime
{

  public static inline function nullize<T>(t:T):Null<T> return t;

  public static
  #if (!java) inline #end // Don't inline for Java targets, because of https://github.com/HaxeFoundation/haxe/issues/3094
  function isNotNull<T>(maybeNull:Null<T>):Bool return maybeNull != null;

  public static function yieldUnknownFieldMap(
    unknownFieldMap:UnknownFieldMap,
    yield:YieldFunction<JsonStreamPair>, onComplete:Void->Void):Void
  {
    Continuation.cpsFunction(
      function(
        unknownFieldMap:UnknownFieldMap,
        yield:YieldFunction<JsonStreamPair>):Void
      {
        for (key in unknownFieldMap.underlying.keys())
        {
          var value = unknownFieldMap.underlying.get(key);
          var valueStream = JsonSerializer.serializeRaw(value);
          yield(new JsonStreamPair(key, valueStream)).async();
        }
      })(unknownFieldMap, yield, onComplete);
  }

  public static function serializeUnknwonEnumValue(unknownEnumValue:UnknownEnumValue):JsonStream return
  {
    switch (unknownEnumValue)
    {
      case UNKNOWN_CONSTANT_CONSTRUCTOR(constructorName):
        JsonStream.STRING(constructorName);
      case UNKNOWN_PARAMETERIZED_CONSTRUCTOR(constructorName, parameters):
        JsonStream.OBJECT(
          new Generator(
            Continuation.cpsFunction(
              function(yield:YieldFunction<JsonStreamPair>):Void
                yield(
                  new JsonStreamPair(
                    constructorName,
                    JsonSerializer.serializeRaw(parameters))).async())));
    }
  }

  public static function serializeUnknown(unknown:Dynamic):JsonStreamPair return
  {
    var unknownType = Std.instance(unknown, UnknownType);
    if (unknownType != null)
    {
      new JsonStreamPair(
        unknownType.type,
        JsonSerializer.serializeRaw(unknownType.data));
    }
    else
    {
      var property = Reflect.getProperty(unknown, "unknownType");
      var unknownType = Std.instance(property, UnknownType);
      if (unknownType != null)
      {
        new JsonStreamPair(
          unknownType.type,
          JsonSerializer.serializeRaw(unknownType.data));
      }
      else
      {
        throw NO_SERIALIZER_FOR_DATA(unknown);
      }
    }
  }

}

/**
  调用`JsonSerializer.serialize`时可能抛出的异常。
**/
enum JsonSerializerError
{
  NO_SERIALIZER_FOR_DATA(data:Dynamic);
}
