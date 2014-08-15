package com.qifun.jsonStream;
@:final
class CSharpEntities
{

  public function new() { }
  #if cs
  public var list = new dotnet.system.collections.generic.List<Int>();
  public var hashSet = new dotnet.system.collections.generic.HashSet<Int>();
  public var dictionary = new dotnet.system.collections.generic.Dictionary<Int, Int>();
  #end
}
