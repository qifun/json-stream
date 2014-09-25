package com.qifun.jsonStream;

import haxe.unit.TestCase;
import com.qifun.jsonStream.testUtil.JsonTestCase;
import com.qifun.jsonStream.crossPlatformTypes.StmRef;
import haxe.Int64;

class Int64Test extends JsonTestCase
{

/*
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
*/
}