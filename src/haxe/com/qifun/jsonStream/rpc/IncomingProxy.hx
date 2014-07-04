package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.JsonStream;

@:autoBuild(com.qifun.jsonStream.rpc.IncomingProxyGenerator.buildFromSuperClass())
class IncomingProxy<ServiceInterface>
{
  var service(get, never):ServiceInterface;

  // 由用户实现
  function get_service():ServiceInterface
  {
    throw "Not implemented!";
  }

  // 由宏实现
  // function incomingRpc(request:JsonStream, handler:JsonStream->Void):Void;
}
