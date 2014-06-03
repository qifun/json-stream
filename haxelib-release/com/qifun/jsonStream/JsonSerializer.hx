package com.qifun.jsonStream;

import com.dongxiguo.continuation.utils.Generator;
import com.dongxiguo.continuation.Continuation;
import com.qifun.jsonStream.JsonStream;
import Type in StdType;
#if macro
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
**/
@:final
class JsonSerializer
{

  private static function iterateJsonObject(instance:Dynamic) return
  {
    Continuation.cpsFunction(function(yield:YieldFunction<JsonStreamPair>):Void
    {
      for (field in Reflect.fields(instance))
      {
        yield(new JsonStream.JsonStreamPair(field, serializeRaw(Reflect.field(instance, field)))).async();
      }
    });
  }
  
  private static function iterateJsonArray(instance:Array<RawJson>) return
  {
    Continuation.cpsFunction(function(yield:YieldFunction<JsonStream>):Void
    {
      for (element in instance)
      {
        yield(serializeRaw(element)).async();
      }
    });
  }

  /**
    Returns a stream that reads data from `instance`.
  **/
  @:noUsing
  public static function serializeRaw(instance:RawJson):JsonStream return
  {
    switch (StdType.typeof(instance.underlying))
    {
      case TObject:
        JsonStream.OBJECT(new Generator(iterateJsonObject(instance.underlying)));
      case TClass(String):
        JsonStream.STRING(instance.underlying);
      case TClass(Array):
        JsonStream.ARRAY(new Generator(iterateJsonArray(instance.underlying)));
      case TInt:
        JsonStream.NUMBER((instance:Dynamic));
      case TFloat:
        JsonStream.NUMBER((instance:Dynamic));
      case TBool if ((instance:Dynamic)):
        JsonStream.TRUE;
      case TBool if (!(instance:Dynamic)):
        JsonStream.FALSE;
      case TNull:
        JsonStream.NULL;
      case t:
        throw 'Unsupported instance data: $t';
    }
  }
  
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

  macro public static function serialize(data:Expr):ExprOf<JsonStream> return
  {
    macro $data.pluginSerialize();
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

  private var serializingTypes(default, null) = new StringMap<BaseType>();

  private static var allBuilders = new StringMap<JsonSerializerGenerator>();

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

  public function buildFields():Array<Field> return
  {
    var meta = buildingClass.meta;

    meta.add(
      ":access",
      [ macro com.qifun.jsonStream.JsonSerializerRuntime ],
      Context.currentPos());

    for (serializingType in serializingTypes)
    {
      var accessPack = MacroStringTools.toFieldExpr(serializingType.pack);
      var accessName = serializingType.name;
      meta.add(
        ":access",
        [ accessPack == null ? macro $i{accessName} : macro $accessPack.$accessName ],
        Context.currentPos());
    }

    // TODO: Dynamic
    //var dynamicCases:Array<Case> = [];
//
    //for (localUsing in Context.getLocalUsing())
    //{
      //var baseType:BaseType = switch (localUsing.get())
      //{
        //case { kind: KAbstractImpl(a) } : a.get();
        //case classType: classType;
      //}
      //var moduleExpr = MacroStringTools.toFieldExpr(baseType.module.split("."));
      //var nameField = baseType.name;
      //var pluginSerializeField = TypeTools.findField(localUsing.get(), "pluginSerialize", true);
      //if (pluginSerializeField != null && !pluginSerializeField.meta.has(":noDynamicSerialize"))
      //{
        //var expr = macro $moduleExpr.$nameField.pluginSerialize(new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginData(valueStream));
        //var temporaryFunction = macro function (valueStream:com.qifun.jsonStream.JsonStream) return $expr;
        //var typedTemporaryFunction = Context.typeExpr(temporaryFunction);
        //var resolvedTemporaryFunction = Context.getTypedExpr(typedTemporaryFunction);
        //var fullName = switch (Context.follow(typedTemporaryFunction.t))
        //{
          //case TFun(_, Context.follow(_) => TInst(_.get() => { module: module, name: name }, _)): getFullName(module, name);
          //case TFun(_, Context.follow(_) => TAbstract(_.get() => { module: module, name: name }, _)): getFullName(module, name);
          //case TFun(_, Context.follow(_) => TEnum(_.get() => { module: module, name: name }, _)): getFullName(module, name);
          //case t: continue;
        //}
        //dynamicCases.push(
        //{
          //values: [ macro $v{ fullName } ],
          //expr: macro ($resolvedTemporaryFunction(valueStream):Dynamic),
        //});
      //}
    //}
//
    //for (methodName in serializingTypes.keys())
    //{
      //var baseType = serializingTypes.get(methodName);
      //var fullName = getFullName(baseType.module, baseType.name);
      //dynamicCases.push(
        //{
          //values: [ macro $v{ fullName } ],
          //expr: macro ($i{methodName}(valueStream):Dynamic),
        //});
    //}
//
    //var switchExpr =
    //{
      //pos: Context.currentPos(),
      //expr: ESwitch(macro dynamicTypeName, dynamicCases, macro null),
    //}
    // trace(ExprTools.toString(switchExpr));
    
    //buildingFields.push(
      //{
        //name: "dynamicSerialize",
        //pos: Context.currentPos(),
        //meta: [ { name: ":noUsing", pos: Context.currentPos(), } ],
        //access: [ APublic, AStatic ],
        //kind: FFun(extractFunction(macro function(dynamicTypeName:String, valueStream:com.qifun.jsonStream.JsonStream):Dynamic return $switchExpr)),
      //});
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
                  var parameterValue = resolvedSerialize(TypeTools.toComplexType(arg.t), macro parameterPair.value, enumAndValueParams);
                  var f =
                  {
                    pos: Context.currentPos(),
                    expr: EFunction(
                      "inline_temporaryEnumSerialize",
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
                        $i{parameterName} = nullize(temporaryEnumSerialize());
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
                    macro $i{unknownFieldMapName}.underlying.set(parameterPair.key, com.qifun.jsonStream.JsonSerializer.serializeRaw(parameterPair.value));
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
                      macro $i{parameterName};
                    }
                  ]),
              };
              block.push(
                macro
                {
                  var generator = com.qifun.jsonStream.JsonSerializer.JsonSerializerRuntime.asGenerator(parameterPairs);
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
                      throw com.qifun.jsonStream.JsonSerializer.JsonSerializeError.UNMATCHED_JSON_TYPE(pair.value, [ "OBJECT" ]);
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
          macro com.qifun.jsonStream.unknown.UnknownEnumValue.UNKNOWN_PARAMETERIZED_CONSTRUCTOR(
            pair.key,
            com.qifun.jsonStream.JsonSerializer.serializeRaw(pair.value));
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
      case OBJECT(pairs):
        function selectEnumValue(pair:com.qifun.jsonStream.JsonStream.JsonStreamPair) return $processObjectBody;
        com.qifun.jsonStream.JsonSerializer.JsonSerializerRuntime.optimizedExtract1(
          pairs,
          selectEnumValue);
      case NULL:
        null;
      case _:
        throw com.qifun.jsonStream.JsonSerializer.JsonSerializeError.UNMATCHED_JSON_TYPE(stream, [ "STRING", "OBJECT", "NULL" ]);
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
    var implExpr = resolvedSerialize(TypeTools.toComplexType(abstractType.type), macro stream, params);
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
    var hasUnknownFieldMap = false;
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
            hasUnknownFieldMap = true;
          case { kind: FVar(AccNormal | AccNo, AccNormal | AccNo), }:
            var fieldName = field.name;
            var s = resolvedSerialize(TypeTools.toComplexType(applyTypeParameters(field.type)), macro data.$fieldName, params);
            blockExprs.push(macro yield(new com.qifun.jsonStream.JsonStream.JsonStreamPair($v { fieldName }, $s)).async());
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

  private static var VOID_COMPLEX_TYPE(default, never) =
    TPath({ name: "Void", pack: []});

  public function tryAddSerializeMethod(type:Type):Void
  {
    switch (Context.follow(type))
    {
      case TInst(_.get() => classType, _) if (!classType.isInterface && classType.kind.match(KNormal)):
        var methodName = serializeMethodName(classType.pack, classType.name);
        if (serializingTypes.get(methodName) == null)
        {
          serializingTypes.set(methodName, classType);
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
          serializingTypes.set(methodName, enumType);
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
          serializingTypes.set(methodName, abstractType);
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

  public static function dynamicSerialize(stream:ExprOf<JsonStream>, expectedComplexType:ComplexType):Expr return
  {
    var localUsings = Context.getLocalUsing();
    function createFunction(i:Int, key:ExprOf<String>, value:ExprOf<JsonStream>):Expr return
    {
      if (i < localUsings.length)
      {
        var classType = localUsings[i].get();
        var field = TypeTools.findField(classType, "dynamicSerialize", true);
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
            var result = $modulePath.$className.dynamicSerialize($key, $value);
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
          macro new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginStream<$expectedComplexType>($value).serializeUnknown($key);
        }
        else
        {
          var classType = getContextBuilder().buildingClass;
          var modulePath = MacroStringTools.toFieldExpr(classType.module.split("."));
          var className = classType.name;
          macro
          {
            var knownValue = untyped($modulePath.$className).dynamicSerialize($key, $value);
            if (knownValue == null)
            {
              new com.qifun.jsonStream.JsonSerializer.JsonSerializerPluginStream<$expectedComplexType>($value).serializeUnknown($key);
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
          com.qifun.jsonStream.JsonSerializer.JsonSerializerRuntime.optimizedExtract1(
            pairs,
            function(dynamicPair) return $processDynamic);
        case NULL:
          null;
        case _:
          throw com.qifun.jsonStream.JsonSerializer.JsonSerializeError.UNMATCHED_JSON_TYPE(stream, [ "OBJECT", "NULL" ]);
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

  public static function generatedSerialize(expectedType:Type, stream:ExprOf<JsonStream>):Expr return
  {
    switch (Context.follow(expectedType))
    {
      case TInst(_.get() => classType, _) if (!classType.isInterface && classType.kind.match(KNormal)):
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
              return macro $pathExpr.$methodName($stream);
            }
            else
            {
              return dynamicSerialize(stream, TypeTools.toComplexType(expectedType));
            }
          }
        }
        var contextBuilder = getContextBuilder();
        if (contextBuilder.serializingTypes.get(methodName) == null)
        {
          contextBuilder.serializingTypes.set(methodName, classType);
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
          macro untyped($buildingClassExpr).$methodName($stream);
        }
        else
        {
          dynamicSerialize(stream, TypeTools.toComplexType(expectedType));
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
            return macro $pathExpr.$methodName($stream);
          }
        }
        var contextBuilder = getContextBuilder();
        if (contextBuilder.serializingTypes.get(methodName) == null)
        {
          contextBuilder.serializingTypes.set(methodName, enumType);
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
        macro untyped($buildingClassExpr).$methodName($stream);
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
              return macro $pathExpr.$methodName($stream);
            }
            else
            {
              return dynamicSerialize(stream, TypeTools.toComplexType(expectedType));
            }
          }
        }
        var contextBuilder = getContextBuilder();
        if (contextBuilder.serializingTypes.get(methodName) == null)
        {
          contextBuilder.serializingTypes.set(methodName, abstractType);
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
          macro untyped($buildingClassExpr).$methodName($stream);
        }
        else
        {
          dynamicSerialize(stream, TypeTools.toComplexType(expectedType));
        }
      case t:
        dynamicSerialize(stream, TypeTools.toComplexType(expectedType));
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
    // trace(ExprTools.toString(Context.getTypedExpr(Context.typeExpr(placeholderExpr))));
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