package ;
using com.qifun.jsonStream.rpc.Future;
import com.qifun.jsonStream.rpc.OutgoingProxyFactory;

using com.qifun.jsonStream.Plugins;

class Rpc2Test extends JsonTestCase
{

  function foo()
  {
    var s:Future<Int->String->Void> = null;
//    s.onComplete(function(i:Int, s:String){}, function(e){});

  }

}

@:build(com.qifun.jsonStream.rpc.OutgoingProxyFactory.generateOutgoingProxyFactory(["Services"]))
class Rpc2OutgoingProxyFactory
{

}


//
//@:build(com.qifun.jsonStream.rpc.IncomingProxyFactory.generateIncomingProxyFactory(["Services"]))
//class Rpc2IncomingProxyFactory
//{
//
//}
//
