package com.qifun.jsonStream.rpc;

@:final
class IncomingProxy implements IJsonRpc
{

  var underlying:JsonStream->Future<JsonStream->Void>;

  public function new(underlying:JsonStream->Future<JsonStream->Void>)
  {
    this.underlying = underlying;
  }

  public function apply(request:JsonStream):Future<JsonStream->Void>
  {
    return underlying(request);
  }

}
