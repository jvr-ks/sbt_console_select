//** useImports=swing_REPL.imports */
def longRunningTask: IO[String] =
  IO.sleep(5.seconds) *> IO.pure("Done")


