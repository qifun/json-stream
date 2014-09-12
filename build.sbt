haxeJavaSettings

haxeCSharpSettings

for (c <- Seq(Compile, Test)) yield {
  haxeOptions in c ++=
    Seq("-D", "scala", "-D", "stateless_future")
}

for (c <- Seq(Compile, Test, CSharp, TestCSharp)) yield {
  haxeOptions in c ++=
    Seq(
      "-D", "no-root",
      "-D", "json_stream_no_dot",
      "-lib", "continuation")
}

for (c <- Seq(CSharp, TestCSharp)) yield {
  haxeOptions in c ++= Seq("-lib", "HUGS", "-D", "CF", "-D", "unity")
}

haxeOptions in Test ++= Seq("-main", "com.qifun.jsonStream.Main")

haxeOptions in Compile ++= Seq("--macro", "com.qifun.util.Patcher.noExternalDoc()")

javacOptions in (Compile, compile) += "-Xlint:-deprecation"

doxPlatforms := Seq("java", "cs")

libraryDependencies += "org.scala-stm" %% "scala-stm" % "0.7"

libraryDependencies += "com.qifun" %% "stateless-future" % "0.3.1"

libraryDependencies += "com.qifun" %% "stateless-future-util" % "0.5.0"

libraryDependencies += "com.qifun" % "haxe-util" % "0.1.0" % HaxeJava classifier "haxe-java"

libraryDependencies += "com.qifun" %% "haxe-scala-library" % "0.1.0" % HaxeJava classifier "haxe-java"

libraryDependencies += "com.novocode" % "junit-interface" % "0.10" % "test"

resolvers in ThisBuild += "Sonatype Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots/"

resolvers in ThisBuild += "Typesafe repository releases" at "http://repo.typesafe.com/typesafe/releases/"

libraryDependencies += "org.reactivemongo" %% "reactivemongo" % "0.11.0-SNAPSHOT"
