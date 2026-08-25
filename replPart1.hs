
var a = 0
{ println(s"level ${a}")
  { a += 1
    println(s"level ${a}")
  
    println(s"still level ${a}")
    { a += 1
      println(s"still level ${a}")
    } 
    a -= 1
    println(s"level ${a} again ")
  }
  a -= 1
  println(s"level ${a} again ")
}

/** showmessage3000=Finished! */


