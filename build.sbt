haxeSettings

haxeOptions ++= Seq("-lib", "continuation")

haxeOptions ++= Seq("-dce", "no")

haxeOptions ++= Seq("-D", "stateless_future")

javacOptions in (Compile, compile) += "-Xlint:-deprecation"

doxPlatforms := Seq("java", "cs")

resolvers += "Sonatype Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots/"

resolvers += "Typesafe repository releases" at "http://repo.typesafe.com/typesafe/releases/" 

libraryDependencies ++= Seq(
  "org.reactivemongo" %% "reactivemongo" % "0.11.0-SNAPSHOT"
)

