package ;
import com.qifun.jsonStream.unknown.UnknownEnumValue;

enum NewEnum<T>
{
  A(b:T);
  B;
  C<T2>(t:T, t2:T2);
  UNKNOWN_ENUM_VALUE(uev:UnknownEnumValue);
}
