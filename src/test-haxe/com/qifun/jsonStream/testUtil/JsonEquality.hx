/*
 * json-stream
 * Copyright 2014 深圳岂凡网络有限公司 (Shenzhen QiFun Network Corp., LTD)
 * 
 * Author: 杨博 (Yang Bo) <pop.atry@gmail.com>, 张修羽 (Zhang Xiuyu) <95850845@qq.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.qifun.jsonStream.testUtil;
import haxe.PosInfos;
class JsonEquality
{

  @:noUsing
  public static function deepEquals(left:Dynamic, right:Dynamic):Bool
  {
    if (left == right)
    {
      return true;
    }
    switch ([ Type.typeof(left), Type.typeof(right) ])
    {
      case
        [ TFloat, TFloat ] |
        [ TInt, TInt ] |
        [ TBool, TBool ] |
        [ TClass(String), TClass(String) ]:
      {
        return left == right;
      }
      case [ TClass(Array), TClass(Array) ]:
      {
        var leftArray:Array<Dynamic> = left;
        var rightArray:Array<Dynamic> = right;
        if (leftArray.length != rightArray.length)
        {
          return false;
        }
        for (i in 0...leftArray.length)
        {
          if (!deepEquals(leftArray[i], rightArray[i]))
          {
            return false;
          }
        }
        return true;
      }
      #if cs
        case [ TClass(leftClass), TClass(rightClass)] if (leftClass == rightClass && Std.is(left, dotnet.system.collections.IEnumerable)):
        {
          var leftEnumerable:dotnet.system.collections.IEnumerable = cast left;
          var rightEnumerable:dotnet.system.collections.IEnumerable = cast left;
          var leftEnumerator = leftEnumerable.GetEnumerator();
          var rightEnumerator = rightEnumerable.GetEnumerator();
          while (true)
          {
            var leftEnumeratorHasNext = leftEnumerator.MoveNext();
            var rightEnumeratorHasNext = rightEnumerator.MoveNext();
            if (leftEnumeratorHasNext && rightEnumeratorHasNext)
            {
              if (deepEquals(untyped leftEnumerator.Current, untyped rightEnumerator.Current))
                continue;
              else 
                return false;
            }
            else if (leftEnumeratorHasNext || rightEnumeratorHasNext)
            {
              return false;
            }
            else
            {
              return true;
            }
          }
        }
      #end
      case [ TClass(_), TClass(_) ]:
      {
        var leftFields = Reflect.fields(left);
        var rightFields = Reflect.fields(right);
        if (leftFields.length != rightFields.length)
        {
          return false;
        }
        for (fieldName in rightFields)
        {
          if (!deepEquals(
            Reflect.field(left, fieldName),
            Reflect.field(right, fieldName)))
          {
            return false;
          }
        }
        return true;
      }
      case [ TObject, TObject ]:
      {
        var leftFields = Reflect.fields(left);
        var rightFields = Reflect.fields(right);
        if (leftFields.length != rightFields.length)
        {
          return false;
        }
        for (fieldName in rightFields)
        {
          if (!deepEquals(
            Reflect.field(left, fieldName),
            Reflect.field(right, fieldName)))
          {
            return false;
          }
        }
        return true;
      }
      case _:
      {
        return false;
      }
    }
  }

}
