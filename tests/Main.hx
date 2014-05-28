package  ;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
#if !macro
import com.qifun.jsonStream.RawJson;
using com.qifun.jsonStream.JsonSerializer;
using com.qifun.jsonStream.JsonDeserializer;
using com.qifun.jsonStream.Plugins;
#end

using Main;

class InlineVar
{
  public static var NotInline = "not" + "inline";
  public static inline var Inline = "inline";
  public static inline function inlineFunction() return "inlineFunction";
}

@:build(com.qifun.jsonStream.JsonDeserializer.buildDeserializer(["Ref"]))
class RefDeserializer { }

@:build(com.qifun.jsonStream.JsonDeserializer.buildDeserializer(["Ref", "NewClass", "NewEnum"]))
class AllDeserializer {}

typedef F<A> = Array<A>->A;
/**
 * @author 杨博
 */
class Main 
{
  macro static function forceTyped(e:Expr):Expr return
  {
    //trace(TypeTools.toString(Context.typeof(macro function (x) return x.pluginDeserialize())));
    
    
    //var r = Context.getTypedExpr(Context.typeExpr(e));
    //trace(ExprTools.toString(r));
    //r;
    e;
  }
	#if !macro
  static function main()
  {
    var ref:Ref<Dynamic> = JsonDeserializer.deserialize(null);
    //forceTyped(
    //var f = function (x) return x.pluginDeserialize()
    //);
////    $type(f);
////    StringDeserializer.pluginDeserialize.bind();
    //var n = switch ("")
    //{
      //case InlineVar.Inline: 2;
      //case "3": 3;
      //case InlineVar.NotInline: 1;
      //case _: 4;
    //}
    //trace((new RawJson("b11aa").serialize().pluginDeserialize():RawJson));
    ////trace(new RawJson( { "xx": [ { }, { "t": 23 } ] } ).serialize().pluginDeserialize());
    ////
    //try
    //{
      //var aad:Array<Array<Dynamic>> = new RawJson([[[]]]).serialize().pluginDeserialize();
    //}
    //catch(error:String)
    //{
      //trace(error);
    //}
 //
    //var b1:Array<Array<Int>> = new RawJson([]).serialize().pluginDeserialize();
//
    //var b2:NewClass = new RawJson({}).serialize().pluginDeserialize();
    //
    //var b3:Array<NewClass> = new RawJson([]).serialize().pluginDeserialize();
    //
    //var m = JsonDeserializer.newDeserializerSet(["Ref", "NewClass"]);
    //trace(m);
    //var nc = function(x) return m.deserialize_NewClass(x);
    //var m2 = JsonDeserializer.newDeserializerSet(["Ref"]);
    //var m3 = JsonDeserializer.newDeserializerSet(["NewEnum"]);
//
  }
	#end
}

interface C<T>
{
  function get():T;
}

class A implements C<A>
{
  var dd(get, set):Int;
  
  public function set_dd(value:Int):Int
  {
    return value;
  }
  public function get_dd():Int
  {
    return 1;
  }
  
  public function get():A return this;
  
  public function new()
  {
    
  }
}