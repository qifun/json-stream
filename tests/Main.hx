package  ;

using com.qifun.jsonStream.Typed;
using com.qifun.jsonStream.Untyped;

/**
 * @author 杨博
 */
class Main 
{
	
	static function main() 
	{
    trace("b11aa".toStream().toInstance());
    trace( { "xx": [ { }, { "t": 23 } ] } .toStream().toInstance());
    var m = Typed.getToInstanceFunction(["NewClass"]);
    
    var nc = m.getClassDescriptor(NewClass);
    
    var a = new A();
    trace(Type.getInstanceFields(A));
    
    var aa = new A();
    Reflect.setProperty(aa, "xx", 1);
    
    var a:Void -> Void;
    var b:Void -> Void = null;
    a = function() {
      b();
    }
    b = function() {
      a();
    }
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