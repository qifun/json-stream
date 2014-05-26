package com.qifun.jsonStream;

/**
 * ...
 * @author 杨博
 */
class UnexpectedJsonType implements IStreamException<JsonStream>
{
  private var stream:JsonStream;

  public function new(stream:JsonStream) 
  {
    this.stream = stream;
  }
  
  /* INTERFACE com.qifun.jsonStream.IStreamException.IStreamException<Stream> */
  
  public function recover():JsonStream return
  {
    stream;
  }
  
}

class ExpectArray extends UnexpectedJsonType 
{
  public function toString() return
  {
    'Expect ARRAY, actual $stream';
  }
}

class ExpectNumber extends UnexpectedJsonType
{
  public function toString() return
  {
    'Expect NUMBER, actual $stream';
  }
}