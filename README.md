JSON Stream
===========

<div align="right"><a href="https://travis-ci.org/qifun/json-stream"><img alt="Build Status" src="https://travis-ci.org/qifun/json-stream.png?branch=master"/></a></div>

**JSON Stream** is a efficient universal serialization framework for JSON and BSON.

## Features

* Serializes in-memory dynamical-typed objects to JSON texts or BSON binary streams, and vice versa.
* Serializes in-memory schematic statically-typed class instances to JSON texts or BSON binary streams, and vice versa.
* Converts JSON texts to BSON binaries, and vice versa.
* Creates incoming and outgoing proxy for RPC interfaces.
* Generates code to achieve the above goals in any of these programming languages:
  * Haxe
  * Java
  * C++
  * C#
  * PHP
  * JavaScript
  * ActionScript3 / Flash
  * Python
  * Neko

## Usage

JSON Stream is written in Haxe, which is able to compile to many other programming language. To use JSON Stream in the target languages, you need these steps:

1. Define your statical entity classes in Haxe.
2. Define deserializer and serializer for your entity classes in Haxe.
3. Compile your Haxe definitions and JSON Stream library to your target language.
4. Use JSON Stream API in your target language.

## Design

### `JsonStream`

`com.qifun.jsonStream.JsonStream` is the universal intermedia type for most of conversions. It is a hierarchical iterator created from an object, an input stream or a string. And then, the `JsonStream` is able to produce another object, output stream, or string.

### Dynamically-typed objects

`com.qifun.jsonStream.RawJson` is the in-memory type that represents dynamically-typed JSON/BSON objects.

``` haxe
// Example.hx

var data = new RawJson(
{
  message: "Hello, World!",
  myArray: [ 1, 3, 5 ],
});

// Creates a JsonStream from an in-memory object.
var jsonStream = JsonSerializer.serializeRaw(data);

// Produces a string from a JsonStream
var jsonString = PrettyTextPrinter.toString(jsonStream);
trace(jsonString);


// Creates another JsonStream from the in-memory object.
var jsonStream2 = JsonSerializer.serializeRaw(data);

// Produces a another in-memory object from a JsonStream
var duplicatedData = JsonDeserializer.deserializeRaw(jsonStream2);
trace(duplicatedData.message);
```

The above example may be written in languages other than Haxe, too.

### Statically-typed Serialization / Deserialization

`JsonStream`s are able to convert from / to statically-typed class instances. The conversion functions can be generated from `com.qifun.jsonStream.JsonDeserializerGenerator` and `com.qifun.jsonStream.JsonSerializerGenerator`.

``` haxe
// MyModule.hx

@:final class MyClass
{
  public function new() {}
  public var foo:Int;
  public var bar:String;
}
```

``` haxe
// Conversions.hx

using com.qifun.jsonStream.Plugins;

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer([ "MyModule" ]))
class MyDeserializer {}

@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer([ "MyModule" ]))
class MySerializer {}
```

``` haxe
// Sample.hx

import com.qifun.jsonStream.io.PrettyTextPrinter;
import com.qifun.jsonStream.io.TextParser;
import com.qifun.jsonStream.JsonDeserializer;
import com.qifun.jsonStream.JsonSerializer;
using com.qifun.jsonStream.Plugins;
using Conversions;

class Sample
{
  public static function main()
  {
    var jsonText = "{ \"foo\": 1, \"bar\": \"Hello, World!\" }";

    // Creates a JsonStream from text.
    var jsonStream = TextParser.parseString(jsonText);

    // Deserialize a MyClass from a JsonStream
    var myClass:MyModule.MyClass = JsonDeserializer.deserialize(jsonStream);

    // Output: Hello, World!
    trace(myClass.bar);

    // Serialize a MyClass to a JsonStream
    var jsonStream2 = JsonSerializer.serialize(myClass);

    // Convert a JsonStream to string.
    var jsonText2 = PrettyTextPrinter.toString(jsonStream2);

    /*
      Output:
      {
      	"foo": 1,
      	"bar": "Hello, World!"
      }
     */
    trace(jsonText2);
  }
}
```

