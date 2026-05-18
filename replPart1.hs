{
val lowerUC = (x: Int, y: Int) => x > y
val lower = lowerUC.curried // convert (x: Int, y: Int) to (x: Int)(y: Int)
val lower25 = lower(25) // partially-applied function

List(10,15,25,30,35,40).filter(lower25)

}

