package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonStream;


@:autoBuild(com.qifun.jsonStream.rpc.OutgoingProxyGenerator.buildFromSuperClass())
class OutgoingProxy<ServiceInterface>
{
  // 由用户实现
  @:protected function outgoingRpc(request:JsonStream, handler:AsynchronousJsonStream->Void):Void
  {
    throw "Not implemented!";
  }

  // 宏实现若干Service中的方法
}
