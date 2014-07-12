package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.JsonStream;


class OutgoingProxy
{

  var outgoingRpc:IJsonRpc;

  public function new(outgoingRpc:IJsonRpc)
  {
    this.outgoingRpc = outgoingRpc;
  }

  // 宏实现若干Service中的方法
}
