package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonStream;


@:autoBuild(com.qifun.jsonStream.rpc.OutgoingProxyGenerator.build("com.qifun.jsonStream.rpc.IOutgoingProxy", "IOutgoingProxy"))
interface IOutgoingProxy<ServiceInterface>
{
  // 由用户实现
  function outgoingRpc(request:JsonStream, handler:AsynchronousJsonStream->Void):Void;

  // 宏实现若干Service中的方法
}
