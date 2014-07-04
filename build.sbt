haxeSettings

haxeOptions ++= Seq("-lib", "continuation")

haxeOptions ++= Seq("-dce", "no")

javacOptions += "-Xlint:-deprecation"

doxPlatforms := Seq("java", "cs")
