package com.qifun.jsonStream;

import haxe.unit.TestCase;
import com.qifun.jsonStream.testUtil.JsonTestCase;
import com.qifun.jsonStream.crossPlatformTypes.StmRef;
import haxe.Int64;

enum Int64Enum
{
  INT64(i:Int64);
}

//这是haxe的测试用例，为了不影响持续继承，在haxe彻底修复以前注释掉这个bug
/*
class Int64Test extends JsonTestCase
{
  
  function testInt64InEnum()
  {
    var i64 = INT64(Int64.make(5, 5));
    switch (i64)
    {
      case INT64(i):
      {
        assertMatch(5, Int64.getHigh(i));
        assertMatch(5, Int64.getLow(i));
      }
    }
  }


  function testInt64AsRefParameter()
  {
    #if (scala && java)
      var int64Stm:StmRef<Int64> = StmRef.empty();
      assertDeepEquals(Int64.make(0, 0), int64Stm.underlying.single().get());
    #else
      var i64 = Int64.make(5, 5);
      var int64Stm:StmRef<Int64> = new StmRef(i64);
      assertDeepEquals(i64, int64Stm.underlying);
    #end
  }

}*/