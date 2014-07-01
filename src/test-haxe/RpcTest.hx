package ;
import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.rpc.IIncomingProxy;
import com.qifun.jsonStream.rpc.IOutgoingProxy;

using com.qifun.jsonStream.Plugins;

/**
 * ...
 * @author 杨博
 */
class RpcTest extends JsonTestCase
{


}

interface IMyService
{
  function foo<CC>(parameter1:CC, parameter2:Int, handler:Float->Void):Void;
  inline function bar(parameter1:String, parameter2:Int, handler:Float->Void):Void;
  dynamic function baz(parameter1:String, parameter2:Int, handler:Float->Void):Void;
}

class MyServiceImplementation implements IMyService
{
  public function new(){}

  public function foo<CC>(parameter1:CC, parameter2:Int, handler:Float->Void):Void
  {
    // TODO:
  }
  public function bar(parameter1:String, parameter2:Int, handler:Float->Void):Void
  {
    // TODO:
  }
  public dynamic function baz(parameter1:String, parameter2:Int, handler:Float->Void):Void
  {
    // TODO:
  }
}

class MyIncomingProxy implements IIncomingProxy<IMyService>
{
  public var service(get, never):IMyService;

  public function get_service()
  {
    return new MyServiceImplementation();
  }
}

class MyOutgoingProxy implements IOutgoingProxy<IMyService>
{
  public function outgoingRpc(request:JsonStream, handler:AsynchronousJsonStream->Void):Void
  {
    // TODO:
  }

}

