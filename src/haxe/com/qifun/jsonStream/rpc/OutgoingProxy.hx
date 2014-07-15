package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.JsonStream;


class OutgoingProxy
{

  var outgoingRpc:IJsonService;

  public function new(outgoingRpc:IJsonService)
  {
    this.outgoingRpc = outgoingRpc;
  }

  // 宏实现若干Service中的方法
}
