package com.qifun.jsonStream.rpc;
import com.dongxiguo.continuation.utils.Generator;
import com.qifun.jsonStream.JsonBuilder;
import com.qifun.jsonStream.JsonStream;
#if macro
import haxe.macro.Expr;
#end
  /**
    双向的RPC会话类。

    请使用`@:build`并传入`JsonRpcSession.build`宏创建会话类实现。

    创建该类实例时，
    必须设置`local_packageName_InterfaceName`为本地接口提供实现，
    还必须设置`send`回调函数，在该回调函数中把数据传给底层连接。

    创建该类实例后，
    可以通过`remote_packageName_InterfaceName`获取远程对端实现的接口。
    收到远端传来的数据时，必须调用`receive`转发给本`JsonRpcSession`。

    示例：

    <pre>`// MySession.hx
@:build(com.qifun.jsonStream.rpc.JsonRpcSession.build([ "myPackage.IMyService" ], [ "yourPackage.IYourService" ]))
class MySession {}`</pre>

    <pre>`// myPackage/IMyService.hx
package myPackage;
typedef ResponseParameter0 = Float;
typedef ResponseParameter1 = Array<Int>;
interface IMyService
{
  function myMethod(
    requestParameter0:Int,
    requestParemeter1:String,
    responseHandler:ResponseParameter0->ResponseParameter1->Void):Void;
}`</pre>
    <pre>`// yourPackage/IYourService.hx
package yourPackage;
interface IYourService
{
  function yourMethod(
    requestParameter0:Int,
    requestParemeter1:String):Void;
}`</pre>

  <pre>`// Sample.hx
import com.qifun.jsonStream.JsonBuilder;
using com.qifun.jsonStream.Plugins;
using MyBuilderFactory;
class Sample
{
  public static function main():Void
  {
    var session = new MySession();
    // 设置本地实现的RPC服务
    session.local_myPackage_MyService = new MyServiceImpl();
    // 设置发送数据用的底层连接
    session.send = ...
    // 发起远程调用
    session.remote_yourPackage_YourService.yourMethod(...);
    // 收到数据时交给session.receive()，以下为伪代码
    while (收到了数据)
    {
      session.receive(收到的数据);
    }
  }
}
class MyServiceImpl implements IMyService
{
  function myMethod(
    requestParameter0:Int,
    requestParemeter1:String,
    responseHandler:ResponseParameter0->ResponseParameter1->Void):Void
  {
    // ...
  }
}`</pre>
  **/
class JsonRpcSession
{

  public function receive(key:String, value:AsynchronousJsonStream):Void
  {

  }

  public var send(null, default):String->JsonStream->Void;

  // public var remote_xxx_xxx_IXxxx(default, null):xxx.xxx.IXxxx;

  // public var local_xxx_xxx_IXxxx(null, default):xxx.xxx.IXxxx;

  /**
    创建`JsonRpcSession`实现类的宏，只能用于`@:build`中。

    `localModules`和`remoteModules`中所有的方法都必须用异步风格定义，
    所以这些方法的返回值必须是`Void`类型。
    <ul>
      <li>
        如果其中某个方法最后一个参数类型为`P0->P1->Void`，
        那么表示这个方法调用的结果由P0和P1组成。
      </li>
      <li>
        而如果某个方法最后一个参数类型不是函数，
        表示这个RPC方法属于单向调用，永远不返回任何值。
      </li>
    </ul>

    本宏会为`localModules`中的每个接口生成只写属性，
    用户通过设置这些属性提供本地接口的实现。

    本宏会为`remoteModules`中的每个接口生成只读属性，
    用户访问这些属性获取远端接口以便发起远程调用。

    @param localModules 本地要实现的接口所在模块。
    @param remoteModules 远端实现的接口所在模块。
  **/
  macro public static function build(
    localModules:Array<String>,
    remoteModules:Array<String>):Array<Field>
  {

  }

}
