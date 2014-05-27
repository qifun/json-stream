package com.qifun.jsonStream;

import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.unknownValue.UnknownFieldMap;
import com.qifun.jsonStream.unknownValue.UnknownType;

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

using Lambda;
using StringTools;

/**
  @author 杨博
**/
class JsonDeserializer
{

  public static function deserializeRaw(stream:JsonStream):RawJson return
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
    });
  }
  
  @:noUsing
  macro public static function buildDeserializer(modules:Array<String>):Array<Field> return
  {
    var deserializer = new JsonDeserializerBuilder(Context.getLocalClass().get(), Context.getBuildFields());
    for (moduleName in modules)
    {
      for (rootType in Context.getModule(moduleName))
      {
        deserializer.tryAddDeserializeMethod(rootType);
      }
    }
    deserializer.buildFields();
  }
  
  macro public static function deserialize<Element>(stream:ExprOf<JsonStream>):ExprOf<Element> return
  {
    var typedJsonStreamTypePath =
    {
      pack: [ "com", "qifun", "jsonStream" ],
      name: "JsonDeserializer",
      sub: "JsonDeserializerPluginStream",
      params: [ TPType(TypeTools.toComplexType(Context.getExpectedType())) ],
    };
    var typedJsonStream =
    {
      pos: Context.currentPos(),
      expr: ENew(typedJsonStreamTypePath, [ stream ]),
    };
    macro $typedJsonStream.pluginDeserialize();
  }
  
}

enum JsonDeserializeErrorCode
{
  TooManyFields<Element>(iterator:Iterator<Element>, expected:Int);
  NotEnoughFields<Element>(iterator:Iterator<Element>, expected:Int, actual:Int);
  UnmatchedJsonType(stream:JsonStream, expected: Array<String>);
}

@:final
class JsonDeserializerBuilder
{

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
        throw TooManyFields(iterator, 1);
      }
      else
      {
        handler(element);
      }
    }
    else
    {
      throw NotEnoughFields(iterator, 1, 0);
    }
  }

  @:extern
  @:noUsing
  private static inline function optimizedExtract1<Element, Result>(iterator:Iterator<Element>, handler:Element->Result):Result return
  {
    switch (Std.instance(iterator, (Generator:Class<Generator<Element>>)))
    {
      case null: extract1(iterator, handler);
      case generator: extract1(generator, handler);
    }
  }
  
#if macro
  private var buildingFields:Array<Field>;

  private var deserializingTypes(default, null) = new StringMap<BaseType>();
  
  private static var allBuilders = new StringMap<JsonDeserializerBuilder>();

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
      [ MacroStringTools.toFieldExpr("com.qifun.jsonStream.JsonDeserializerBuilder".split(".")) ],
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
      switch (Context.follow(Context.typeof(macro $moduleExpr.$nameField.getPluginDynamicType)))
      {
        case TFun([], TAbstract(_.get() => { module: "com.qifun.jsonStream.JsonDeserializer", name: "NonDynamicDeserializer" }, _)):
          continue;
        case TFun([], dynamicType):
          var fullName =
            switch (dynamicType)
            {
              case TInst(_.get() => { module: module, name: name }, _): getFullName(module, name);
              case TAbstract(_.get() => { module: module, name: name }, _): getFullName(module, name);
              case TEnum(_.get() => { module: module, name: name }, _): getFullName(module, name);
              case _: continue;
            }
          var expr = resolvedDeserialize(TypeTools.toComplexType(dynamicType), macro valueStream);
          dynamicCases.push(
            {
              values: [ macro $v{ fullName } ],
              expr: macro ($expr:Dynamic),
            });
        case _:
          continue;
      }
    }
  
    for (methodName in deserializingTypes.keys())
    {
      var baseType = deserializingTypes.get(methodName);
      var fullName = getFullName(baseType.module, baseType.name);
      dynamicCases.push(
        {
          values: [ macro $v{ fullName } ],
          expr: macro (cast $i{methodName}(valueStream):Dynamic),
        });
    }
    
    var switchExpr =
    {
      pos: Context.currentPos(),
      expr: ESwitch(macro dynamicTypeName, dynamicCases, macro null),
    }
    buildingFields.push(
      {
        name: "dynamicDeserialize",
        pos: Context.currentPos(),
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

  private static function getContextBuilder():JsonDeserializerBuilder return
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
  
  function newEnumDeserializeFunction(enumType:EnumType):Function return
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
        case { name: "UNKNOWN_ENUM_VALUE", type: TFun([ { t: TEnum(_.get() => { module: "com.qifun.jsonStream.unknownValue.UnknownEnumValue", name: "UnknownEnumValue" }, _) } ], _) }:
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
                if (arg.name == "unknownFieldMap" && Context.follow(arg.t).match(TAbstract(_.get() => {module: "com.qifun.jsonStream.unknownValue.UnknownFieldMap", name: "UnknownFieldMap"}, [])))
                {
                  if (unknownFieldMapName == null)
                  {
                    unknownFieldMapName = parameterName;
                    block.push(macro $i{parameterName} = new com.qifun.jsonStream.unknownValue.UnknownFieldMap(new haxe.ds.StringMap.StringMap()));
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
                    macro $i{unknownFieldMapName}.set(parameterPair.key, parameterPair.value);
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
                  var generator = com.qifun.jsonStream.JsonDeserializer.JsonDeserializerBuilder.asGenerator(parameterPairs);
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
                      throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializeErrorCode.UnmatchedJsonType(pair.value, [ "OBJECT" ]);
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
          macro com.qifun.jsonStream.unknownValue.UnknownEnumValue.UNKNOWN_PARAMETERIZED_CONSTRUCTOR(
            pair.key,
            com.qifun.jsonStream.JsonDeserializer.deserializeRaw(pair.value));
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
          macro com.qifun.jsonStream.unknownValue.UnknownEnumValue.UNKNOWN_CONSTANT_CONSTRUCTOR(constructorName);
        }),
    }
    var methodBody = macro switch (stream)
    {
      case STRING(constructorName):
        $zeroParameterBranch;
      case OBJECT(pairs):
        function selectEnumValue(pair:com.qifun.jsonStream.JsonStream.PairStream) return $processObjectBody;
        com.qifun.jsonStream.JsonDeserializer.JsonDeserializerBuilder.optimizedExtract1(
          pairs,
          selectEnumValue);
      case NULL:
        null;
      case _:
        throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializeErrorCode.UnmatchedJsonType(stream, [ "STRING", "OBJECT", "NULL" ]);
    }
    {
      args:
      [
        {
          name:"stream",
          type: MacroStringTools.toComplex("com.qifun.jsonStream.JsonStream"),
        },
      ],
      ret: null,
      expr: macro return $methodBody,
      params: enumParams,
    }
  }
  function newAbstractDeserializeFunction(abstractType:AbstractType):Function return
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
      name: abstractModule.substring(abstractType.module.lastIndexOf(".") + 1),
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

  function newClassDeserializeFunction(classType:ClassType):Function return
  {
    var params: Array<TypeParamDecl> =
    [
      for (tp in classType.params)
      {
        name: tp.name,
        // TODO: constraits
      }
    ];
    var cases =
    [
      for (field in classType.fields.get())
      {
        if (field.kind.match(FVar(AccNormal | AccNo, AccNormal | AccNo)))
        {
          var fieldName = field.name;
          var d = resolvedDeserialize(TypeTools.toComplexType(field.type), macro pair.value, params);
          {
            values: [ macro $v{fieldName} ],
            guard: null,
            expr: macro result.$fieldName = $d,
          }
        }
      }
    ];
    var classModule = classType.module;
    var expectedTypePath =
    {
      pack: classType.pack,
      name: classModule.substring(classModule.lastIndexOf(".")),
      sub: classType.name,
    };
    var newInstance =
    {
      pos: Context.currentPos(),
      expr: ENew(expectedTypePath, []),
    }
    var switchKey =
    {
      pos: Context.currentPos(),
      expr: ESwitch(macro pair.key, cases, macro result.get_unknownFieldMap().set(pair.key, pair.value)),
    }
    
    var switchStream = macro switch (stream)
    {
      case OBJECT(pairs):
        var result = $newInstance;
        var generator = com.qifun.jsonStream.JsonDeserializer.JsonDeserializerBuilder.asGenerator(pairs);
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
        throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializeErrorCode.UnmatchedJsonType(stream, [ "OBJECT" ]);
    }
    
    {
      args:
      [
        {
          name:"stream",
          type: MacroStringTools.toComplex("com.qifun.jsonStream.JsonStream"),
        },
      ],
      ret: null,
      expr: macro return $switchStream,
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
              access: [ APublic, AStatic ],
              kind: FFun(newAbstractDeserializeFunction(abstractType)),
            });
        }
      case _:
    }
  }
  
  public static function dynamicDeserialize(stream:ExprOf<JsonStream>, expectedComplexType:ComplexType):Expr return
  {
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
        if (contextBuilder == null)
        {
          macro new com.qifun.jsonStream.JsonDeserializer.JsonDeserializerPluginStream<$expectedComplexType>($value).deserializeUnknown($key);
        }
        else
        {
          var classType = getContextBuilder().buildingClass;
          var modulePath = MacroStringTools.toFieldExpr(classType.module.split("."));
          var className = classType.name;
          macro switch (untyped($modulePath.$className).dynamicDeserialize($key, $value))
          {
            case null:
              new com.qifun.jsonStream.JsonDeserializer.JsonDeserializerPluginStream<$expectedComplexType>($value).deserializeUnknown($key);
            case knownValue:
              knownValue;
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
          com.qifun.jsonStream.JsonDeserializer.JsonDeserializerBuilder.optimizedExtract1(
            pairs,
            function(dynamicPair) return $processDynamic);
        case NULL:
          null;
        case _:
          throw com.qifun.jsonStream.JsonDeserializer.JsonDeserializeErrorCode.UnmatchedJsonType(stream, [ "OBJECT", "NULL" ]);
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
 
  public static function generatedDeserialize(expectedType:Type, stream:ExprOf<JsonStream>):Expr return
  {
    switch (Context.follow(expectedType))
    {
      case TInst(_.get() => classType, _) if (!classType.isInterface && classType.kind.match(KNormal)):
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
              return dynamicDeserialize(stream, TypeTools.toComplexType(expectedType));
            }
          }
        }
        var contextBuilder = getContextBuilder();
        if (contextBuilder.deserializingTypes.get(methodName) == null)
        {
          contextBuilder.deserializingTypes.set(methodName, classType);
          contextBuilder.buildingFields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
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
          dynamicDeserialize(stream, TypeTools.toComplexType(expectedType));
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
              return dynamicDeserialize(stream, TypeTools.toComplexType(expectedType));
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
          dynamicDeserialize(stream, TypeTools.toComplexType(expectedType));
        }
      case t:
        dynamicDeserialize(stream, TypeTools.toComplexType(expectedType));
    }
  }

  // 类似deserialize，但是能递归解决类型，以便能够在@:build宏返回以前就立即执行
  private static function resolvedDeserialize(expectedComplexType:ComplexType, stream:ExprOf<JsonStream>, ?params:Array<TypeParamDecl>):Expr return
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
    //trace(ExprTools.toString(Context.getTypedExpr(Context.typeExpr(placeholderExpr))));
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

#end
}


@:final
extern class FallbackGetPluginDynamicType0
{
  @:extern
  public static function getPluginDynamicType(deserializer:Dynamic):NonDynamicDeserializer return
  {
    throw "Used at compile-time only!";
  }
}


@:final
extern class FallbackGetPluginDynamicType1
{
  @:extern
  public static function getPluginDynamicType<Value>(deserializer:JsonDeserializerPlugin<Value>):Value return
  {
    throw "Used at compile-time only!";
  }
}

/**
 * Internal type for deserializer plugins.
 * @author 杨博
 */
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

typedef JsonDeserializerPlugin<Value> =
{
  function pluginDeserialize(stream:JsonDeserializerPluginStream<Value>):Value;
}

abstract NonDynamicDeserializer(Dynamic) {}


// TODO: 支持继承
class FallbackUnknownTypeJsonDeserializer
{
  @:extern
  public inline static function deserializeUnknown<Element>(stream:JsonDeserializerPluginStream<Element>, type:String):Dynamic return
  {
    null;
  }
}
  
class UnknownTypeSetterJsonDeserializer
{

  @:generic
  @:extern
  public static inline function deserializeUnknown<Result:{ function new():Void; var unkownType(never, set):UnknownType; }>(stream:JsonDeserializerPluginStream<Result>, type:String):Dynamic return
  {
    var result = new Result();
    result.unkownType = new UnknownType(type, JsonDeserializer.deserializeRaw(stream.underlying));
    result;
  }

  
}

class UnknownTypeFieldJsonDeserializer
{

  @:generic
  @:extern
  public static inline function deserializeUnknown<Result:{ function new():Void; var unkownType(null, default):UnknownType; }>(stream:JsonDeserializerPluginStream<Result>, type:String):Dynamic return
  {
    var result = new Result();
    result.unkownType = new UnknownType(type, JsonDeserializer.deserializeRaw(stream.underlying));
    result;
  }

}

abstract DynamicUnknownType(Dynamic) {}

class DynamicUnknownTypeJsonDeserializer
{
  @:extern
  public static inline function deserializeUnknown<T:DynamicUnknownType>(stream:JsonDeserializerPluginStream<T>, type:String):Dynamic return
  {
    new com.qifun.jsonStream.unknownValue.UnknownType(type, com.qifun.jsonStream.JsonDeserializer.deserializeRaw(stream.underlying));
  }
}

class FallbackGetUnknownFieldMap
{

  @:extern
  public static inline function get_unknownFieldMap(d:Dynamic) return FallbackGetUnknownFieldMap;

  @:extern
  @:noUsing
  public static inline function set(key:String, value:JsonStream):Void {}

}

class HasUnknownFieldMapField
{
  
  @:extern
  public static inline function get_unknownFieldMap(o: { var unknownFieldMap(default, null):UnknownFieldMap; } ) return o.unknownFieldMap;

}

class HasUnknownFieldMapGetter
{
  
  @:extern
  public static inline function get_unknownFieldMap(o: { var unknownFieldMap(get, never):UnknownFieldMap; } ) return o.unknownFieldMap;

}