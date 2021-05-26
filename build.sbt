// build.sbt

inThisBuild(
	List(
		scalaVersion := "2.13.4"
	)
)
 
 
val default = "latest.integration"
val Http4sVersion = "0.21.15"
val CirceVersion = "0.13.0"
val MunitVersion = "0.7.20"
val MunitCatsEffectVersion = "0.12.0"
//val LogbackVersion = "1.2.3"
val SourcecodeVersion = "0.1.9"
val Svm_subsVersion = "20.2.0"
val ConfigVersion = "1.4.1"



lazy val javaFXModules = Seq("base", "controls", "fxml", "graphics", "media", "swing", "web")

lazy val root = (project in file("."))
.settings(
	name := "__testarea",
	organization := "de.jvr",
	version := "0.004",
	//semanticdbEnabled := true, // enable SemanticDB
	//semanticdbVersion := scalafixSemanticdb.revision, // use Scalafix compatible version
		
	logLevel := Level.Warn,

	libraryDependencies ++= Seq(
		"com.github.pathikrit"			%% "better-files-akka"		% default,
		"com.typesafe.akka"				%% "akka-actor"				% default,
		"com.typesafe" 					%  "config"					% ConfigVersion,
		"com.typesafe.akka" 			%% "akka-testkit" 			% default % "test",
		"com.typesafe.scala-logging"	%% "scala-logging"			% default,
        
		"org.scalafx" 					%% "scalafx" 				% default,

		"org.scala-lang.modules" 		%% "scala-xml" 				% default,

		"ch.qos.logback" 				%  "logback-classic" 		% default,
        
		"com.lihaoyi" 					%% "sourcecode"				% SourcecodeVersion,
		"com.lihaoyi"					%% "fastparse"				% default,
		"com.lihaoyi" 					%% "sourcecode"				% SourcecodeVersion,
		"com.lihaoyi"					%% "fansi"					% "0.2.10",
        
		"io.circe"       				%% "circe-generic"			% CirceVersion,
        
		"org.scalameta"					%% "munit"					% MunitVersion           % Test,
		"org.scalameta"					%% "scalameta"				% default,
 		"org.scalameta"					%% "svm-subs"				% Svm_subsVersion,
        
		"org.typelevel"					%% "munit-cats-effect-2"	% MunitCatsEffectVersion % Test,
		"org.typelevel"					%% "cats-core"				% default,
		"org.typelevel"					%% "cats-free"				% default,
		"org.typelevel"					%% "cats-mtl-core"			% default,
		"org.typelevel"					%% "cats-laws"				% default,
		"org.typelevel"					%% "spire"					% default,
        
		"org.scalamacros"				%  "paradise_2.13.0-M3"		% "2.1.1",
		"org.scalamacros"				%% "resetallattrs"			% "1.0.0",
        
		"org.scala-lang"				%  "scala-reflect"			% "2.13.3"
	),
    scalacOptions ++= Seq(
      "-deprecation",
      "-encoding", "UTF-8",
      "-feature",
      "-language:_"
	  //"-Ymacro-annotations"
    ),
    addCompilerPlugin("org.typelevel" %% "kind-projector"     % "0.10.3"),
    addCompilerPlugin("com.olegpy"    %% "better-monadic-for" % "0.3.1"),
    testFrameworks += new TestFramework("munit.Framework"),
	
	libraryDependencies ++= javaFXModules.map( m => "org.openjfx" % s"javafx-$m" % default)
)



  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  