package com.qifun.jsonStream;

import com.dongxiguo.continuation.utils.Generator;
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
 * @author 杨博
 */
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

  @:extern
  @:noUsing
  private static inline function asGenerator<Element>(iterator:Iterator<Element>):Null<Generator<Element>> return
  {
    Std.instance(iterator, (Generator:Class<Generator<Element>>));
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


#if macro
@:final
class JsonDeserializerBuilder
{
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
      [ MacroStringTools.toFieldExpr("com.qifun.jsonStream.JsonDeserializer".split(".")) ],
      Context.currentPos());

    for (deserializingType in deserializingTypes)
    {
      meta.add(
        ":access",
        [ MacroStringTools.toFieldExpr(getFullName(deserializingType.module, deserializingType.name).split(".")) ],
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
      switch (Context.follow(Context.typeof(macro $moduleExpr.$nameField.getDynamicDeserializerType)))
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
  
  var buildingClass:ClassType;
  
  // id的格式：packageNames.ModuleName.ClassName
  var id(get, never):String;

  public function get_id() return
  {
    buildingClass.module + "." + buildingClass.name;
  }

  public function new(buildingClass:ClassType, buildingFields:Array<Field>)
  {
    this.buildingClass = buildingClass;
    this.buildingFields = buildingFields;
    allBuilders.set(id, this);
  }

  public static function getContextBuilder():JsonDeserializerBuilder return
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
    var cases = [];
    for (constructor in enumType.constructs)
    {
      switch (constructor.type)
      {
        case TFun(args, _):
          var valueParams: Array<TypeParamDecl> =
          [
            for (tp in constructor.params)
            {
              name: tp.name,
              // TODO: constraits
            }
          ];
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
                  var result = resolvedDeserialize(TypeTools.toComplexType(args[i].t), macro $i { parameterName }, enumParams.concat(valueParams));
                  var f = {
                    pos: Context.currentPos(),
                    expr: EFunction(
                      "inline_temporaryEnumDeserialize",
                      {
                        params: valueParams,
                        ret: null,
                        args: [],
                        expr: macro return $result,
                      })
                  }
                  macro { $f; temporaryEnumDeserialize(); }
                }
              ];
              var declareProcessParameters =
              {
                pos: Context.currentPos(),
                expr:
                  EFunction(null,
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
              var numArguments = args.length;
              ({
                values: [ macro $v{constructorName} ],
                expr: macro
                {
                  switch (pair.value)
                  {
                    case com.qifun.jsonStream.JsonStream.ARRAY(parameters):
                      com.qifun.jsonStream.IteratorExtractor.optimizedExtract(
                        parameters,
                        $v{numArguments},
                        com.qifun.jsonStream.IteratorExtractor.identity, // FIXME:
                        com.qifun.jsonStream.IteratorExtractor.identity, // FIXME:
                        $declareProcessParameters);
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
    var methodBody = macro switch (stream)
    {
      case STRING(constructorName):
        $zeroParameterBranch;
      case OBJECT(pairs):
        function selectEnumValue(pair) return $processObjectBody;
        com.qifun.jsonStream.IteratorExtractor.optimizedExtract1(
          pairs,
          com.qifun.jsonStream.IteratorExtractor.identity,
          com.qifun.jsonStream.IteratorExtractor.identity,
          selectEnumValue);
      case _:
        throw "Expect object or string!";
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
    var unknownFieldBranch =
      macro Reflect.setProperty(
        result,
        pair.key,
        com.qifun.jsonStream.JsonDeserializer.JsonDeserializer.deserializeRaw(pair.value));
    var switchKey =
    {
      pos: Context.currentPos(),
      expr: ESwitch(macro pair.key, cases, unknownFieldBranch),
    }
    
    var switchStream = macro switch (stream)
    {
      case OBJECT(pairs):
        var result = $newInstance;
        var generator = com.qifun.jsonStream.JsonDeserializer.JsonDeserializer.asGenerator(pairs);
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
  
  public static function dynamicDeserialize(stream:ExprOf<JsonStream>):Expr return
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
          macro null;
        }
        else
        {
          var classType = getContextBuilder().buildingClass;
          var modulePath = MacroStringTools.toFieldExpr(classType.module.split("."));
          var className = classType.name;
          macro untyped($modulePath.$className).dynamicDeserialize($key, $value);
        }
      }
    }
    var processDynamic = createFunction(0, macro dynamicPair.key, macro dynamicPair.value);
    macro (function(stream:com.qifun.jsonStream.JsonStream):Dynamic return
    {
      switch (stream)
      {
        case OBJECT(pairs):
          com.qifun.jsonStream.IteratorExtractor.optimizedExtract1(
            pairs, 
            com.qifun.jsonStream.IteratorExtractor.identity,
            com.qifun.jsonStream.IteratorExtractor.identity,
            function(dynamicPair) return $processDynamic);
        case NULL:
          null;
        case _:
          throw "Expect object!";
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
              return dynamicDeserialize(stream);
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
          dynamicDeserialize(stream);
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
              return dynamicDeserialize(stream);
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
          dynamicDeserialize(stream);
        }
      case t:
        dynamicDeserialize(stream);
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

}
#end


@:final
extern class GetDynamicDeserializerTypeNonDynamicDeserializer
{
  @:extern
  public static function getDynamicDeserializerType(deserializer:Dynamic):NonDynamicDeserializer return
  {
    throw "Used at compile-time only!";
  }
}


@:final
extern class GetDynamicDeserializerType
{
  @:extern
  public static function getDynamicDeserializerType<Value>(deserializer:JsonDeserializerPlugin<Value>):Value return
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

  public inline function new(underlying:JsonStream) 
  {
    this = underlying;
  }
  
  public var underlying(get, never):JsonStream;
  
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

typedef UnknownFieldHandler<Parent> =
{
  function handleUnknownField(parent:Parent, fieldName: String, fieldValue: JsonStream):Void;
  function handleUnknownArrayElement<Element>(parent:Array<Element>, index: Int, fieldValue: JsonStream):Void;
}

@:final
class FallbackUnknownFieldHandler
{
  // 默认抛出异常
  public static function handleUnknownField<Parent>(parent:Parent, fieldName: String, fieldValue: JsonStream):Void
  {
    throw 'Unknown field $fieldName: ${JsonDeserializer.deserializeRaw(fieldValue)} is received when deserializing $parent!';
  };
}

// TODO: 支持继承