//** useImports=swing_REPL.imports */
def longRunningTask: IO[String] =
  IO.sleep(5.seconds) *> IO.pure("Done")

def setStatus(label: Label, text: String): IO[Unit] =
  IO(label.text = text)

