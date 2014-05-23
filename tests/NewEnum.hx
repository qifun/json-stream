package ;

/**
 * @author 杨博
 */

enum NewEnum<T>
{
  A(b:T);
  B;
  C<T2>(t:T, t2:T2);
}