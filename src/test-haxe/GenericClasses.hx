package ;
import haxe.ds.Vector;

interface IHasArray<A>
{
  var array:Array<A>;
}

class BaseClass<B, A>
{
  public function new() {}

  public var a1:A;
  public var array:Array<A>;
  public var self:Null<BaseClass<A, BaseClass<B, Int>>>;
  public var self2(default, default):Null<BaseClass<A, B>>;
}

class BaseClass2<A, B, C> extends BaseClass<Array<B>, A> implements IHasArray<A>
{

  public var a2:A;
  var array2:Array<IHasArray<C>>;
  var array3:Array<IHasArray<FinalClass<Dynamic>>>;
  var vector5:Vector<C>;

}

@:final
class FinalClass<G> extends BaseClass2<Array<Array<BaseClass<G, BaseClass<G, Dynamic>>>>, String, Array<G>>
{
  var array4:Array<FinalClass<Dynamic>>;
}

@:final
class FinalClass2<A, B> extends BaseClass<A,B>
{
  //var vector1:Vector<Int>; // 由于Haxe的bug，Java平台无法使用Vector<Int>
  var vector2:Vector<A>;
  var vector3:Vector<B>;
  var vector4:Vector<String>;
}
