// build.sbt

// https://mvnrepository.com/artifact/org.typelevel/cats-core
val catsVersion = "2.13.0"

// Source: https://mvnrepository.com/artifact/org.typelevel/cats-effect
val catseffectVersion = "3.7-4972921"

// Source: https://mvnrepository.com/artifact/co.fs2/fs2-core
val fs2Version = "3.13.0"

// Source: https://mvnrepository.com/artifact/com.lihaoyi/fansi
val fansiVersion = "0.5.1"

// Source: https://mvnrepository.com/artifact/com.lihaoyi/os_lib
val os_libVersion = "0.11.9-M8"

// Source: https://mvnrepository.com/artifact/org.scala-lang.modules/scala_swing
val scala_swingVersion = "3.0.0"

// https://github.com/scodec/scodec
// Source: https://mvnrepository.com/artifact/org.scodec/scodec-core
val scodecVersion = "2.3.3"

// Source: https://mvnrepository.com/artifact/org.creativescala/doodle-core
val doodleVersion = "0.34.0"

lazy val catsCore = "org.typelevel" %% "cats-core" % catsVersion
lazy val catsFree = "org.typelevel" %% "cats-free" % catsVersion
lazy val catsLaws = "org.typelevel" %% "cats-laws" % catsVersion

lazy val catseffectKernel = "org.typelevel" %% "cats-effect-kernel" % catseffectVersion
lazy val catseffectstd = "org.typelevel" %% "cats-effect-std" % catseffectVersion
lazy val catseffect = "org.typelevel" %% "cats-effect" % catseffectVersion

lazy val fs2core = "co.fs2" %% "fs2-core" % fs2Version
lazy val fs2io = "co.fs2" %% "fs2-io" % fs2Version
lazy val fs2reactivestreams = "co.fs2" %% "fs2-reactive-streams" % fs2Version
lazy val fs2scodec = "co.fs2" %% "fs2-scodec" % fs2Version

lazy val fansi = "com.lihaoyi" %% "fansi" % fansiVersion
lazy val os_lib = "com.lihaoyi" %% "os-lib" % os_libVersion

lazy val scala_swing = "org.scala-lang.modules" %% "scala-swing" % scala_swingVersion

     
      
inThisBuild(
  List(
    scalaVersion := "3.8.2", 
  )
)

lazy val root = (project in file("."))
  .settings(
    name := "TEST",
    libraryDependencies ++= Seq(
      catsCore,
      catsFree,
      catseffectKernel,
      catseffectstd,
      catseffect,
      fs2core,
      fs2io,
      fs2reactivestreams,
      fs2scodec,
      fansi,
      os_lib,
      scala_swing,
    ),
    // https://docs.scala-lang.org/scala3/guides/migration/options-lookup.html
    scalacOptions ++= Seq(
      "-feature",
      "-deprecation",
      "-unchecked",
    ),
  )

// nur bei Java > 21:


Compile / console / fork := true

javaOptions ++= Seq(
  "-Xms1G",
  "-Xmx4G",
  "--enable-native-access=ALL-UNNAMED"
)
