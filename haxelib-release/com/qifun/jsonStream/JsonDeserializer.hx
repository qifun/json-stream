package com.qifun.jsonStream;

import haxe.ds.IntMap;
import Type in StdType;
import haxe.ds.StringMap;
import haxe.ds.Vector;
import com.dongxiguo.continuation.utils.Generator;
#if macro
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
#end

using StringTools;
using Lambda;

@:final
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
  @:allow(com.qifun.jsonStream.generated)
  @:noUsing
  private static inline function asGenerator<Element>(iterator:Iterator<Element>):Null<Generator<Element>> return
  {
    Std.instance(iterator, (Generator:Class<Generator<Element>>));
  }
  
  @:noUsing
  macro public static function newDeserializerSet(modules:Array<String>, ?fullName:String):ExprOf<JsonDeserializerSet> return
  {
    var deserializerSetBuilder = new JsonDeserializerSetBuilder(fullName != null ? fullName : defaultDeserializerSetFullName());
    for (moduleName in modules)
    {
      for (rootType in Context.getModule(moduleName))
      {
        deserializerSetBuilder.tryAddDeserializeMethod(rootType);
      }
    }
    deserializerSetBuilder.defineDeserializerSet();
  }
  
  macro public static function deserialize<Element>(stream:ExprOf<JsonStream>):ExprOf<Element> return
  {
    var deserializerSetBuilder = new JsonDeserializerSetBuilder(defaultDeserializerSetFullName());
    var result = deserializerSetBuilder.deserializeForType(TypeTools.toComplexType(Context.getExpectedType()), stream);
    deserializerSetBuilder.defineDeserializerSet();
    result;
  }
  
  #if macro
  
    private static var idSeed = 0;

    private static function defaultDeserializerSetFullName() return
    {
      function generateName(baseType:BaseType):String return
      {
        var id = idSeed++;
        var sb = [ "com.qifun.jsonStream.generated" ].concat(baseType.pack);
        sb.push("JsonDeserializerSet_" + id);
        sb.join(".");
      }

      switch (Context.getLocalType())
      {
        case TInst(t, _): generateName(t.get());
        case TAbstract(t, _): generateName(t.get());
        case TEnum(t, _): generateName(t.get());
        case TType(t, _): generateName(t.get());
        case unsupportedType: throw "Expect BaseType, actual " + unsupportedType;
      }
    }

  #end

}

#if macro
@:final
class JsonDeserializerSetBuilder
{
  private var fields(default, null):Array<Field> = [];
  
  private var deserializingTypes(default, null) = new StringMap<BaseType>();
  
  private static var allBuilders = new StringMap<JsonDeserializerSetBuilder>();
  
  var internalPackage(get, never):Array<String>;
  function get_internalPackage():Array<String> return
  {
    var p = id.split(".");
    p.pop();
    p;
  }
  
  var id:String;
  
  var placeholderName(get, never):String;
  function get_placeholderName() return
  {
    deserializerSetName + DESERIALIZER_SET_PLACEHOLDER_SUFFIX;
  }
  
  var deserializerSetName(get, never):String;
  function get_deserializerSetName() return
  {
    id.substring(id.lastIndexOf(".") + 1);
  }
  
  public function new(deserializerSetFullName:String)
  {
    this.id = deserializerSetFullName;
    allBuilders.set(id, this);
    var typeDefinition =
    {
      pack: internalPackage,
      name: placeholderName,
      pos: Context.currentPos(),
      kind: TDAlias(TPath({pack: [], sub: "Dynamic", name: "StdTypes"})),
      fields: [],
    }
    Context.defineType(typeDefinition);
  }

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

  public function defineDeserializerSet():ExprOf<JsonDeserializerSet> return
  {
    var meta =
    [
      for (deserializingType in deserializingTypes)
      {
        //var m = MacroStringTools.toFieldExpr(getFullName(deserializingType.module, deserializingType.name));
        //var n = deserializingType.name;
        {
          name: ":access",
          params: [ MacroStringTools.toFieldExpr(getFullName(deserializingType.module, deserializingType.name).split(".")) ],
          pos : Context.currentPos(),
        }
      }
    ];

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
          var expr = deserializeForType(TypeTools.toComplexType(dynamicType), macro pair.value);
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
          expr: macro (cast $i{methodName}(pair.value):Dynamic),
        });
    }
    
    var switchExpr =
    {
      pos: Context.currentPos(),
      expr: ESwitch(macro pair.key, dynamicCases, macro throw "Unknown type "+ pair.key),
    }
    var extractOne = optimizedExtract(macro pairs, 1, macro processDynamicPair);
    var dynamicDeserialize =
      macro switch (stream)
      {
        case com.qifun.jsonStream.JsonStream.OBJECT(pairs):
          inline function processDynamicPair(pair) return $switchExpr;
          $extractOne;
        case _:
          throw "Expect object!";
      }
    fields.push(
      {
        name: "dynamicDeserialize",
        pos: Context.currentPos(),
        access: [ APublic, AStatic ],
        kind: FFun(extractFunction(macro function(stream:com.qifun.jsonStream.JsonStream):Dynamic return $dynamicDeserialize)),
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
    //trace(new haxe.macro.Printer().printTypeDefinition(typeDefinition));
    Context.defineType(typeDefinition);
    fields = null;
    allBuilders.remove(id);
    var internalPackageExpr = MacroStringTools.toFieldExpr(internalPackage);
    macro $internalPackageExpr.$deserializerSetName;
  }
  
  private static inline var DESERIALIZER_SET_PLACEHOLDER_SUFFIX = "__Placeholder";
  
  public static function getContextBuilder():JsonDeserializerSetBuilder return
  {
    switch (Context.typeof(macro currentJsonDeserializerSet()))
    {
      case TType(_.get() => { module: module }, _) if (module.endsWith(DESERIALIZER_SET_PLACEHOLDER_SUFFIX)):
        allBuilders.get(module.substring(0, module.length - DESERIALIZER_SET_PLACEHOLDER_SUFFIX.length));
      case _:
        throw "Cannot find a context JsonDeserializerSetBuilder!";
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

  private static function optimizedExtract<Element>(iterator:ExprOf<Iterator<Element>>, numParametersExpected:Int, handler:Expr):Expr return
  {
    var extractFromIterator = extract(macro iterator, numParametersExpected, handler);
    var extractFromGenerator = extract(macro generator, numParametersExpected, handler);
    macro
    {
      var iterator = $iterator;
      var generator = com.qifun.jsonStream.JsonDeserializer.JsonDeserializer.asGenerator(iterator);
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
    
  public function tryAddDeserializeMethod(type:Type):Null<String> return
  {

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
      var extractOne = optimizedExtract(macro pairs, 1, macro processObject);
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
                    var result = deserializeForType(TypeTools.toComplexType(args[i].t), macro $i { parameterName }, enumParams.concat(valueParams));
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
                    EFunction("processParameters",
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
          function processObject(pair) return
          {
            $processObjectBody;
          }
          $extractOne;
        };
      var methodBody = macro switch (stream)
      {
        case STRING(constructorName):
          $zeroParameterBranch;
        case OBJECT(pairs):
          $nonzeroParameterBranch;
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
      var implExpr = deserializeForType(TypeTools.toComplexType(abstractType.type), macro stream, params);
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
            var d = deserializeForType(TypeTools.toComplexType(field.type), macro pair.value, params);
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
    switch (Context.follow(type))
    {
      case TInst(_.get() => classType, _) if (!classType.isInterface && classType.kind.match(KNormal)):
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
        if (classType.meta.has(":final"))
        {
          methodName;
        }
        else
        {
          null;
        }
      case TEnum(_.get() => enumType, _):
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
        methodName;
      case TAbstract(_.get() => abstractType, _):
        var methodName = deserializeMethodName(abstractType.pack, abstractType.name);
        if (deserializingTypes.get(methodName) == null)
        {
          deserializingTypes.set(methodName, abstractType);
          fields.push(
            {
              name: methodName,
              pos: Context.currentPos(),
              access: [ APublic, AStatic ],
              kind: FFun(newAbstractDeserializeFunction(abstractType)),
            });
        }
        methodName;
      case _:
        null;
    }
  }


  public function deserializeForType(expectedType:ComplexType, stream:ExprOf<JsonStream>, ?params:Array<TypeParamDecl>):Expr return
  {
    var typedJsonStreamTypePath =
    {
      pack: [ "com", "qifun", "jsonStream" ],
      name: "JsonDeserializer",
      sub: "JsonDeserializerPluginStream",
      params: [ TPType(expectedType) ],
    };
    var typedJsonStreamType = TPath(typedJsonStreamTypePath);
    var placeholderType = TPath(
    {
      pack: internalPackage,
      name: placeholderName,
    });
    var p = MacroStringTools.toFieldExpr(internalPackage);
    var f = 
    {
      expr: 
        EFunction("temporaryDeserialize",
        {
          args: [ { name: "typedJsonStream", type: typedJsonStreamType } ],
          ret: expectedType,
          expr: macro return typedJsonStream.deserialize(),
          params: params,
        }),
      pos: Context.currentPos()
    }
    var placeholderExpr = macro
    {
      // 提供一个假的currentJsonDeserializerSet，以避免编译错误，然后后续处理时，再替换掉它
      function currentJsonDeserializerSet():$placeholderType return null;
      $f;
      null;
    }
    //trace(ExprTools.toString(Context.getTypedExpr(Context.typeExpr(placeholderExpr))));
    switch (Context.getTypedExpr(Context.typeExpr(placeholderExpr)))
    {
      case { expr: EBlock([ _, { expr: EFunction(_, resolved) | EVars([ { expr: {expr: EFunction(null, resolved)}}])}, _ ]) } :
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
          inline function currentJsonDeserializerSet() return $p.$deserializerSetName;
          $f;
          temporaryDeserialize($typedJsonStream);
        }
      case t:
        throw "Expect EBlock, actual " + ExprTools.toString(t);
    };
  }

}
#end

typedef JsonDeserializerSet =
{
  function dynamicDeserialize(typeName:String, stream:JsonStream):Dynamic;
}


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
  function deserialize(stream:JsonDeserializerPluginStream<Value>):Value;
}

abstract NonDynamicDeserializer(Dynamic) {}
// TODO: 支持继承