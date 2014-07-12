haxeSettings

haxeOptions ++= Seq("-lib", "continuation")

haxeOptions ++= Seq("-dce", "no")

haxeOptions ++= Seq("-D", "stateless_future")

javacOptions in (Compile, compile) += "-Xlint:-deprecation"

doxPlatforms := Seq("java", "cs")

libraryDependencies += "com.qifun" %% "stateless-future" % "0.2.2"
