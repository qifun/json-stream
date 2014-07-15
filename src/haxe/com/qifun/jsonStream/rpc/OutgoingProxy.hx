package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.JsonStream;


class OutgoingProxy
{

  var outgoingRpc:IJsonMethod;

  public function new(outgoingRpc:IJsonMethod)
  {
    this.outgoingRpc = outgoingRpc;
  }

  // 宏实现若干Service中的方法
}
