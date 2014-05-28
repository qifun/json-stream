package com.qifun.jsonStream.serializerPlugin;

//import com.dongxiguo.continuation.utils.Generator;
//import com.qifun.jsonStream.JsonStream;
//import com.qifun.jsonStream.JsonSerializer;
//import haxe.Int64;
//
//@:final
//class Int64SerializerPlugin
//{
  //public static function pluginDeserialize(data:Int64):JsonStream return
  //{
    //switch (stream.underlying)
    //{
      //case com.qifun.jsonStream.JsonStream.ARRAY(elements):
        //optimizedExtractInt64(elements);
      //case NULL:
        //null;
      //case _:
        //throw "Expect number";
    //}
  //}
//}
//
//@:final
//class IntSerializerPlugin
//{
  //public static function pluginDeserialize(stream:JsonSerializerPluginStream<Int>):Null<Int> return
  //{
    //switch (stream.underlying)
    //{
      //case com.qifun.jsonStream.JsonStream.NUMBER(value):
        //cast value;
      //case NULL:
        //null;
      //case _:
        //throw "Expect number";
    //}
  //}
//}
//
//@:final
//class UIntSerializerPlugin
//{
  //public static function pluginDeserialize(stream:JsonSerializerPluginStream<UInt>):Null<UInt> return
  //{
    //switch (stream.underlying)
    //{
      //case com.qifun.jsonStream.JsonStream.NUMBER(value):
        //cast value;
      //case NULL:
        //null;
      //case _:
        //throw "Expect number";
    //}
  //}
//}
//
//#if (java || cs)
  //@:final
  //class SingleSerializerPlugin
  //{
    //public static function pluginDeserialize(stream:JsonSerializerPluginStream<Single>):Null<Single> return
    //{
      //switch (stream.underlying)
      //{
        //case com.qifun.jsonStream.JsonStream.NUMBER(value):
          //value;
        //case NULL:
          //null;
        //case _:
          //throw "Expect number";
      //}
    //}
  //}
//#end
//
//@:final
//class FloatSerializerPlugin
//{
  //public static function pluginDeserialize(stream:JsonSerializerPluginStream<Float>):Null<Float> return
  //{
    //switch (stream.underlying)
    //{
      //case com.qifun.jsonStream.JsonStream.NUMBER(value):
        //value;
      //case NULL:
        //null;
      //case _:
        //throw "Expect number";
    //}
  //}
//}
//
//@:final
//class BoolSerializerPlugin
//{
  //public static function pluginDeserialize(stream:JsonSerializerPluginStream<Bool>):Null<Bool> return
  //{
    //switch (stream.underlying)
    //{
      //case com.qifun.jsonStream.JsonStream.FALSE: false;
      //case com.qifun.jsonStream.JsonStream.TRUE: true;
      //case NULL:
        //null;
      //case _: throw "Expect false | true";
    //}
  //}
//}
//
//@:final
//class StringSerializerPlugin
//{
  //public static function pluginDeserialize(stream:JsonSerializerPluginStream<String>):Null<String> return
  //{
    //switch (stream.underlying)
    //{
      //case com.qifun.jsonStream.JsonStream.STRING(value):
        //value;
      //case NULL:
        //null;
      //case _:
        //throw "Expect string";
    //}
  //}
//}
//
//@:final
//class ArraySerializerPlugin
//{
//
  //@:extern
  //public static function getDynamicSerializerPluginType():Null<Array<Dynamic>> return
  //{
    //throw "Used at compile-time only!";
  //}
//
  //public static function deserializeForElement<Element>(stream:JsonSerializerPluginStream<Array<Element>>, elementDeserializeFunction:JsonSerializerPluginStream<Element>->Element):Array<Element> return
  //{
    //switch (stream.underlying)
    //{
      //case com.qifun.jsonStream.JsonStream.ARRAY(value):
        //var generator = Std.instance(value, (Generator:Class<Generator<JsonStream>>));
        //if (generator != null)
        //{
          //[
            //for (element in generator)
            //{
              //elementDeserializeFunction(new JsonSerializerPluginStream(element));
            //}
          //];
        //}
        //else
        //{
          //[
            //for (element in value)
            //{
              //elementDeserializeFunction(new JsonSerializerPluginStream(element));
            //}
          //];
        //}
      //case NULL:
        //null;
      //case _:
        //throw "Expect array";
    //}
  //}
  //
  //macro public static function pluginDeserialize<Element>(stream:ExprOf<JsonSerializerPluginStream<Array<Element>>>):ExprOf<Array<Element>> return
  //{
    //macro com.qifun.jsonStream.SerializerPlugin.PrimitiveSerializerPlugins.ArraySerializerPlugin.deserializeForElement($stream, function(substream) return substream.pluginDeserialize());
  //}
//}
//
////TODO : StringMap and IntMap
