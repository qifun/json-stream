package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.rpc.IJsonService;

@:final
class IncomingProxy implements IJsonService
{

  var underlying:JsonStream->IJsonResponseHandler->Void;

  public function new(underlying:JsonStream->IJsonResponseHandler->Void)
  {
    this.underlying = underlying;
  }

  public function apply(request:JsonStream, responseHandler:IJsonResponseHandler):Void
  {
    underlying(request, responseHandler);
  }

}
