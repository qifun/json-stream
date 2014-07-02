package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonStream;

@:autoBuild(com.qifun.jsonStream.rpc.IncomingProxyGenerator.buildFromInterface("com.qifun.jsonStream.rpc.IIncomingProxy", "IIncomingProxy"))
interface IIncomingProxy<ServiceInterface>
{
  var service(get, never):ServiceInterface;

  // 由用户实现
  function get_service():ServiceInterface;

  // 由宏实现
  function incomingRpc(request:AsynchronousJsonStream, handler:JsonStream->Void):Void;
}
