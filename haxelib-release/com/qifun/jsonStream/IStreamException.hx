package com.qifun.jsonStream;

/**
  @author 杨博
**/
interface IStreamException<Stream>
{

  function recover():Stream;
  
}
