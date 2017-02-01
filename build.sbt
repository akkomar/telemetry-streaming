resolvers ++= Seq(
  "Conjars" at "http://conjars.org/repo",
  "Artima Maven Repository" at "http://repo.artima.com/releases"
)

name := "telemetry-streaming"

version := "0.1-SNAPSHOT"

organization := "com.mozilla"

scalaVersion in ThisBuild := "2.11.8"

val sparkVersion = "2.1.0"

lazy val root = (project in file(".")).
  settings(
    libraryDependencies += "com.trueaccord.scalapb" %% "scalapb-runtime" % com.trueaccord.scalapb.compiler.Version.scalapbVersion % "protobuf",
    libraryDependencies += "org.scalatest" %% "scalatest" % "2.2.1" % "test",
    libraryDependencies += "org.apache.spark" %% "spark-core" % sparkVersion,
    libraryDependencies += "org.apache.spark" %% "spark-streaming" % sparkVersion,
    libraryDependencies += "org.apache.spark" %% "spark-sql" % sparkVersion,
    libraryDependencies += "org.apache.spark" %% "spark-sql-kafka-0-10" % sparkVersion,
    libraryDependencies += "org.rogach" %% "scallop" % "1.0.2"
  )

// Compile proto files
PB.targets in Compile := Seq(
  scalapb.gen() -> (sourceManaged in Compile).value
)

// make run command include the provided dependencies
run in Compile <<= Defaults.runTask(fullClasspath in Compile, mainClass in (Compile, run), runner in (Compile, run))

// exclude Scala library from assembly
assemblyOption in assembly := (assemblyOption in assembly).value.copy(includeScala = false)

// Default SBT settings suck
javaOptions ++= Seq("-Xms512M", "-Xmx2048M", "-XX:MaxPermSize=2048M", "-XX:+CMSClassUnloadingEnabled")

parallelExecution in Test := false
