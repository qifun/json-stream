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
        [ TClass(String), TClass(String) ]
      :
        return left == right;
      case [ TClass(Array), TClass(Array) ]:
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
      case [ TObject, TObject ]:
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
      case _:
        return false;
    }
  }

}
