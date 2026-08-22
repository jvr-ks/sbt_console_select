//----------------------------- swing_REPL.scala -----------------------------
/**
//> using dep ...
are in the file "repl-options.scala"
*/

//** useImports=swing_REPL.imports */
def longRunningTask: IO[String] =
  IO.sleep(5.seconds) *> IO.pure("Done")

def setStatus(label: Label, text: String): IO[Unit] =
  IO(label.text = text)

def run: IO[Unit] =
  Dispatcher.parallel[IO].use { dispatcher =>
    for {
      runningRef <- Ref.of[IO, Option[Fiber[IO, Throwable, Unit]]](None)
      done       <- Deferred[IO, Unit]
      
      _ <- IO {
        val status = new Label("Idle")
        val start  = new Button("Start")
        val cancel = new Button("Cancel")
        
        val frame = new MainFrame {
          title = "Cats Effect + Swing"
          contents = new BorderPanel {
            add(status, North)
            add(new FlowPanel(start, cancel), Center)
          }
          size = new Dimension(300, 140)
        }
        
        frame.visible = true
        
        start.reactions += {
          case event.ButtonClicked(_) =>
            dispatcher.unsafeRunAndForget {
              for {
                old <- runningRef.getAndSet(None)
                _   <- old.traverse_(_.cancel)
                fiber <- (for {
                  _ <- setStatus(status, "Running...")
                  r <- longRunningTask
                  _ <- setStatus(status, r)
                } yield ()).start
                _ <- runningRef.set(Some(fiber))
              } yield ()
            }
        }
        
        cancel.reactions += {
          case event.ButtonClicked(_) =>
            dispatcher.unsafeRunAndForget {
              for {
                fiberOpt <- runningRef.getAndSet(None)
                _        <- fiberOpt.traverse_(_.cancel)
                _        <- setStatus(status, "Canceled")
              } yield ()
            }
        }
        
        frame.peer.addWindowListener(new java.awt.event.WindowAdapter {
          override def windowClosed(e: java.awt.event.WindowEvent): Unit =
            dispatcher.unsafeRunAndForget(done.complete(()).void)
        })
      }
      
      _ <- done.get
    } yield ()
  }


run.unsafeRunSync()




