package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.rpc.IJsonService;

@:dox(hide)
@:final
class JsonHandler implements IJsonResponseHandler
{

  var underlying:JsonResponse->Void;

  public function new(underlying:JsonResponse->Void)
  {
    this.underlying = underlying;
  }

  public function onSuccess(stream:JsonStream):Void
  {
    underlying(SUCCESS(stream));
  }

  public function onFailure(stream:JsonStream):Void
  {
    underlying(FAILURE(stream));
  }

}

@:dox(hide)
enum JsonResponse
{
  SUCCESS(stream:JsonStream);
  FAILURE(stream:JsonStream);
}
