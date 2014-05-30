package com.qifun.jsonStream;

import com.qifun.jsonStream.JsonBuilder;
import com.dongxiguo.continuation.Continuation;

/**
 * @author 杨博
 */
class JsonBuilderFactory
{
  
  public static var ASYNCHRONOUS_DESERIALIZE_RAW(default, never):AsynchronousJsonStream->(RawJson->Void)->Void = Continuation.cpsFunction(function(stream:AsynchronousJsonStream):RawJson return
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
          array.push(ASYNCHRONOUS_DESERIALIZE_RAW(element).async());
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
          Reflect.setField(object, key, ASYNCHRONOUS_DESERIALIZE_RAW(value).async());
        }
        throw "unreachable code";
    });
  });

  public static function newRawBuilder():JsonBuilder<RawJson> return
  {
    new JsonBuilder(ASYNCHRONOUS_DESERIALIZE_RAW);
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
  
  //macro public static function newBuilder<Result>():IRootJsonBuilder<Result> return
  //{
    //
  //}
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

typedef Plugin =
{
  function pluginBeginObject<Result>(stream:JsonBuilderPluginStream<Result>, onComplete:Result->Void):Void;
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
  
}
#end


