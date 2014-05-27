package ;
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
  AFTER_NOON(unknownFields:com.qifun.jsonStream.unknownValue.UnknownFieldMap, xxx:String);
}

class BaseClass<T>
{
  public function new() {}
  private var a:Array<T>;
}

@:final
class FinalClass extends BaseClass<Good> {}