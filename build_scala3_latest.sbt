// build.sbt
// rename this to build.sbt !
// Scala 3 nightly latest

inThisBuild(
	List(
		scalaVersion := sys.env.get("dottyLatestNightlyBuild").getOrElse("3.0.2-RC1-bin-20210624-ecbe3d2-NIGHTLY")
	)
)

val default = "latest.integration"


lazy val root = (project in file("."))
.settings(
	name := "scala3",
	organization := "com.xyz",
	version := "0.001",
		
	logLevel := Level.Warn,

	libraryDependencies ++= Seq(
		//"com.github.pathikrit"				%% "better-files-akka"		% default
	),
		scalacOptions ++= Seq(
			"-deprecation",
			"-encoding", "UTF-8",
			"-feature",
			"-language:_"
		//"-Ymacro-annotations"
		),
		//testFrameworks += new TestFramework("munit.Framework"),
	
)



	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	