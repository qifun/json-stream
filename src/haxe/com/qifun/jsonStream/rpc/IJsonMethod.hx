package com.qifun.jsonStream.rpc;

@:nativeGen
interface IJsonMethod
{
  function apply(request:JsonStream, responseHandler:IJsonResponseHandler):Void;
}

@:nativeGen
interface IJsonResponseHandler
{
  function onSuccess(stream:JsonStream):Void;
  function onFailure(stream:JsonStream):Void;
}
