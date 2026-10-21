import builder._

val result1 = success
val result2 = failure("just cause")

println(result1.getClass)
println(result2.getClass)

val result1: Either[String, Unit] = success
val result2: Either[String, Unit] = failure("just cause")

