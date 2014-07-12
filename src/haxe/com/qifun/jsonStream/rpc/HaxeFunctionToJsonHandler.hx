package com.qifun.jsonStream.rpc;
import com.qifun.jsonStream.JsonStream;


@:dox(hide)
@:final
class HaxeFunctionToJsonHandler implements IJsonHandler
{
  var underlying:JsonStream->Void;

  public function new(underlying:JsonStream->Void)
  {
    this.underlying = underlying;
  }

  public function handle(jsonStream:JsonStream):Void
  {
    underlying(jsonStream);
  }

}
