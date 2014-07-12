package ;

import com.qifun.jsonStream.rpc.Future;

interface IRpc2
{

  public function foo<CC>(parameter1:CC, parameter2:Int):Future < Float->Void > ;

  // Does not support unless https://github.com/HaxeFoundation/haxe/issues/3176 fixed
  // public function bar<CC>(parameter1:CC, parameter2:Int):Future<Array<CC>->Void>;

  public dynamic function baz(parameter1:String, parameter2:Int):Future < Float->Void > ;

}
