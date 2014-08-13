package com.qifun.jsonStream;
import com.qifun.jsonStream.rpc.Future;

@:nativeGen
interface IPingPong
{

  function ping(request:Ping):Future<Pong>;

}
