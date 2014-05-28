package ;
import com.qifun.jsonStream.unknownValue.UnknownFieldMap;
import haxe.Int64;


/**
 * ...
 * @author 杨博
 */
@:final
class NewClass
{

  public function new() 
  {
    
  }
  
  private var r1:Ref<Int>;
  private var r2:Ref<Dynamic>;
  private var r3:Ref<NewClass>;
  
  private var yyy:Array<NewClass>;
  
  public var abs0:Abs2<Int>;
  
  public var abs1:Abs2<NewClass>;
  
  public var abs2:Abs2<Dynamic>;
  
  public var abs3:Abs;
  
  public var xxx:Int;
  
  public var foo:D<Int>;
  
  private var bar(default, null):Good;
  
  public var nc(null, null):NewClass;
  
  var f:FinalClass;
  
  var b:BaseClass<Int>;
}

typedef D<A> = E3<Good>;

abstract Abs2<T>(Array<T>) { }

abstract Abs(String) {}

enum E3<T>
{
  A;
  B<C>(c:C);
}

enum Good
{
  MORNING;
  EVENING(message:String, nc:NewClass, self:Good, i:Int, u:UInt, f:Float, i64:Int64, b:Bool, d:Dynamic);
  AFTER_NOON(unknownFieldMap:com.qifun.jsonStream.unknownValue.UnknownFieldMap, xxx:String);
}

class BaseClass<T>
{
  public function new() {}
  private var b:Array<Good>;
  private var a:Array<T>;
}

class BaseClass2<T> extends BaseClass<BaseClass<T>>
{
  private var c:Array<T>;
  public var unknownFieldMap(get, never):UnknownFieldMap;
  function get_unknownFieldMap():UnknownFieldMap
  {
    return null;
  }
}

class BaseClass3<T> extends BaseClass<BaseClass3<T>>
{
  private var c:Array<T>;
}

@:final
class FinalClass2 extends BaseClass2<BaseClass2<Array<Good>>>
{
  private var d:Array<Good>;
}

@:final
class FinalClass3 extends BaseClass3<BaseClass2<Array<Good>>>
{
  private var d:Array<Good>;
}

@:final
class FinalClass extends BaseClass<Good>
{

  private var c:Array<Good>;
  
}