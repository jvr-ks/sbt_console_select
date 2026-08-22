val run =
  val wait = IO.sleep(5.second)
  val r = Range(1, 10, 1).toList
  
  IO{r.foreach(println)} >>
  IO{println()} >>
  IO{r.foreach(print)} >>
  IO{println()} >>
  IO{r.foreach((x:Int) => print(x.toString + " "))} >>
  IO{println()} >> wait >> IO{println("by by ...")}


//val cancel = run.unsafeRunCancelable()
val cancel = run.unsafeRunSync()


