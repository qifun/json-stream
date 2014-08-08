package ;
using com.qifun.jsonStream.rpc.Future;
import com.qifun.jsonStream.rpc.OutgoingProxyFactory;
import com.qifun.jsonStream.JsonTestCase;
using com.qifun.jsonStream.Plugins;

class Rpc2Test extends JsonTestCase
{

  function foo()
  {
    var s:Future<Int->String->Void> = null;
//    s.onComplete(function(i:Int, s:String){}, function(e){});

  }

}

@:build(com.qifun.jsonStream.rpc.OutgoingProxyFactory.generateOutgoingProxyFactory(["com.qifun.jsonStream.Services"]))
class Rpc2OutgoingProxyFactory
{

}



@:build(com.qifun.jsonStream.rpc.IncomingProxyFactory.generateIncomingProxyFactory(["com.qifun.jsonStream.Services"]))
class Rpc2IncomingProxyFactory
{

}

