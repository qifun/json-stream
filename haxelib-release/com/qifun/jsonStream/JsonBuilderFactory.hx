package com.qifun.jsonStream;

import com.qifun.jsonStream.IJsonBuilder;

/**
 * @author 杨博
 */
class JsonBuilder
{

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
  
  macro public static function newBuilder<Result>():IRootJsonBuilder<Result> return
  {
    
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

abstract JsonBuilderPluginTag<Result>(Dynamic) {}

typedef Plugin =
{
  function pluginBeginObject<Result>(tag:JsonBuilderPluginTag<Result>, setter:Result->Void):Pair<IJsonObjectBuilder, RequireRewrite>
}


#if macro
class JsonBuilderFactoryGenerator
{
  
}
#end


abstract JsonBuilderPluginTag(Dynamic) { }


@:final
private class ProxyJsonBuilder<Parent:LazyJsonObjectBuilder<Dynamic>> implements IJsonBuilder
{
  private var parent:Parent;

  private var key:String;

  public var numberValue(never, set):Float;

  private inline function set_numberValue(value:Float):Float return
  {
    parent.setNumberField(parent, key, value);
  }
 
  public var stringValue(never, set):String;

  private inline function set_stringValue(value:String):String return
  {
    parent.setStringField(parent, key, value);
  }

  public inline function setTrue():Void
  {
    parent.setBoolField(parent, key, true);
  }

  public inline function setFalse():Void
  {
    parent.setBoolField(parent, key, false);
  }

  public inline function setNull():Void
  {
    parent.setNullField(parent, key);
  }

  public inline function beginObject() return
  {
    parent.addObjectPair(parent, key);
  }
  
  public inline function beginArray() return
  {
    parent.addArrayPair(parent, key);
  }

  public function new(parent:Parent, key:String)
  {
    this.parent = parent;
    this.key = key;
  }
}

private class LazyJsonObjectBuilder<Self:LazyJsonObjectBuilder<Self>> implements IJsonObjectBuilder
{
  
  public var setStringField:Self->String->String->String;
  public var setNumberField:Self->String->Float->Float;
  public var setNullField:Self->String->Void;
  public var setBoolField:Self->String->Bool->Void;
  public var addObjectPair:Self->String->IJsonObjectBuilder;
  public var addArrayPair:Self->String->IJsonArrayBuilder;
  public function addPair(key:String):ProxyJsonBuilder<LazyJsonObjectBuilder<Self>> return
  {
    new ProxyJsonBuilder(this, key);
  }

}