object Main extends IOApp.Simple:

  val cp = System.getProperty("file.encoding")

  val run =
    IO.print(s"${RED}${BOLD}Hello ") >> IO.println(s"world,${RESET}\n") >> IO.println(s"${GREEN}${BOLD}from \"Cats-effect\"!${RESET}\n\n") >> IO.println(s"${YELLOW}(codepage: $cp) 😀😀😀${RESET}") >> IO.sleep(new FiniteDuration(10L, SECONDS)).as(ExitCode.Success)
  end run
end Main

/** code part 2 section
Main.run.unsafeRunSync()
*/
