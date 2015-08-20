addSbtPlugin("com.qifun" % "sbt-haxe" % "1.3.0")

addSbtPlugin("com.jsuereth" % "sbt-pgp" % "1.0.0")

lazy val root = project in file(".") dependsOn `sbt-release`

// Use forked sbt-release due to a bug in sbt-release 1.0.1(https://github.com/sbt/sbt-release/pull/122)
lazy val `sbt-release` = RootProject(uri("https://github.com/Atry/sbt-release.git#patch-1"))
