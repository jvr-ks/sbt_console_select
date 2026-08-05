import cats.Eval

val greeting = 
  Eval
  .always{ println("Step 1"); "Hello" }
  .map{ str => println("Step 2"); s"$str world" }
// greeting: Eval[String] = cats.Eval$$anon$4@2319703e

greeting.value
// Step 1
// Step 2
// res16: String = "Hello world"
