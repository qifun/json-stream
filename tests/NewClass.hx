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
  
  public var xxx:Int;
  
  private var bar(default, null):Good;
  
  public var nc(null, null):NewClass;
}

enum Good
{
  MORNING;
  EVENING(message:String, nc:NewClass, self:Good, i:Int, u:UInt, f:Float, i64:Int64, b:Bool);
}