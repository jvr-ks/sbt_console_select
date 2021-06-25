// build.sbt
// Scala 3 nightly latest

inThisBuild(
	List(
		scalaVersion := dottyLatestNightlyBuild.get
	)
)

val default = "latest.integration"


lazy val root = (project in file("."))
.settings(
	name := "scala3",
	organization := "de.jvr",
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



	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	