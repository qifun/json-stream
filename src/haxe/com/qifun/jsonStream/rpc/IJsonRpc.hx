package com.qifun.jsonStream.rpc;

interface IJsonRpc
{
  function apply(request:JsonStream):Future<JsonStream->Void>;
}
