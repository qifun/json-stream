package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.JsonStream;


class OutgoingProxy
{

  var outgoingRpc:JsonStream->(JsonStream->Void)->Void;

  public function new(outgoingRpc:JsonStream->(JsonStream->Void)->Void)
  {
    this.outgoingRpc = outgoingRpc;
  }

  // 宏实现若干Service中的方法
}
