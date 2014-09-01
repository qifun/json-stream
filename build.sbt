haxeJavaSettings

haxeCSharpSettings

haxeOptions ++= Seq("-lib", "continuation")

libraryDependencies += "org.scala-stm" %% "scala-stm" % "0.7"

haxeOptions ++= Seq("-dce", "no")

haxeOptions ++= Seq("-lib", "HUGS")

haxeOptions ++= Seq("-D", "json_stream_no_dot")

haxeOptions in Test ++= Seq("-main", "com.qifun.jsonStream.Main")

haxeOptions in Compile ++= Seq("-D", "stateless_future")

haxeOptions in Test ++= Seq("-D", "stateless_future")

haxeOptions in Compile ++= Seq("-D", "scala_stm")

haxeOptions in Test ++= Seq("-D", "scala_stm")

haxeOptions in Compile ++= Seq("--macro", "com.qifun.util.Patcher.noExternalDoc()")

haxeOptions in Compile ++= Seq("-D", "scala")

haxeOptions in Test ++= Seq("-D", "scala")

javacOptions in (Compile, compile) += "-Xlint:-deprecation"

doxPlatforms := Seq("java", "cs")

libraryDependencies += "com.qifun" %% "stateless-future" % "0.2.2"

libraryDependencies += "com.novocode" % "junit-interface" % "0.10" % "test"

resolvers in ThisBuild += "Sonatype Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots/"

resolvers in ThisBuild += "Typesafe repository releases" at "http://repo.typesafe.com/typesafe/releases/"

libraryDependencies += "org.reactivemongo" %% "reactivemongo" % "0.11.0-SNAPSHOT"
