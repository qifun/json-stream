package  ;

import com.qifun.jsonStream.RawJson;
using com.qifun.jsonStream.RawDeserializer;
using com.qifun.jsonStream.RawSerializer;
using com.qifun.jsonStream.TypedDeserializer;
import com.qifun.jsonStream.TypedJsonStream;

/**
 * @author 杨博
 */
class Main 
{
	
	static function main() 
	{
    trace(new RawJson("b11aa").serialize().deserialize());
    trace(new RawJson( { "xx": [ { }, { "t": 23 } ] } ).serialize().deserialize());
    
    //var b1 = new TypedJsonStream<Array<Array<Int>>>(new RawJson([]).serialize()).deserialize();
    //
    //var b2 = new TypedJsonStream<NewClass>(new RawJson([]).serialize()).deserialize();
    //
    var b3 = new TypedJsonStream<Array<NewClass>>(new RawJson([]).serialize()).deserialize();
    

    //var m = Typed.newDescriptorSet(["NewClass"]);
    //var nc = m.toClassInstance(NewClass);
    //
    //var a = new A();
    //trace(Type.getInstanceFields(A));
    //
    //var aa = new A();
    //Reflect.setProperty(aa, "xx", 1);
    //
    //var a:Void -> Void;
    //var b:Void -> Void = null;
    //a = function() {
      //b();
    //}
    //b = function() {
      //a();
    //}
    //function a(i:Int):Int
    //{
      //return i > 0 ? b(i - 1): 0;
    //}
    //function b(i:Int):Int
    //{
      //return a(i - 1);
    //}
    //a(5);
    
	}
	
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