package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.rpc.IJsonMethod;

@:final
class IncomingProxy implements IJsonMethod
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
