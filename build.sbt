haxeSettings

haxeOptions ++= Seq("-lib", "continuation")

haxeOptions ++= Seq("-dce", "no")

javacOptions in (Compile, compile) += "-Xlint:-deprecation"

doxPlatforms := Seq("java", "cs")
