package ;
import haxe.Int64;

/**
 * ...
 * @author 杨博
 */
class NewClass
{

  public function new() 
  {
    
  }
  
  public var xxx:Int;
  
  public var bar(default, default):Good;
  
  public var nc(default, default):NewClass;
}

enum Good
{
  MORNING;
  EVENING(message:String, nc:NewClass, self:Good, i:Int, u:UInt, f:Float, i64:Int64, b:Bool);
}