// file:///catseffect_3_Typeclasses.scsc

//-------------------------------- Typeclasses --------------------------------
//--------------------------------- Overview ---------------------------------
// https://typelevel.org/cats-effect/docs/typeclasses

  Resource safety and cancelation
  Parallel evaluation
  State sharing between parallel processes
  Interactions with time, including current time and sleep
  Safe capture of side-effects which return values
  Safe capture of side-effects which invoke a callback

//-------------------------------- MonadCancel --------------------------------
// https://typelevel.org/cats-effect/docs/typeclasses/monadcancel
// TODO
A fiber can terminate in three different states, reflected by the different subtypes of Outcome:

sealed trait Outcome[F[_], E, A]
final case class Succeeded[F[_], E, A](fa: F[A]) extends Outcome[F, E, A]
final case class Errored[F[_], E, A](e: E) extends Outcome[F, E, A]
final case class Canceled[F[_], E, A]() extends Outcome[F, E, A]


import cats.effect._
import cats.effect.syntax.all._

openFile.bracket(fis => readFromFile(fis))(fis => closeFile(fis))


import cats.effect.{MonadCancel}
import cats.effect.std.Semaphore
import cats.effect.syntax.all._
import cats.syntax.all._

def guarded[F[_], R, A, E](s: Semaphore[F], alloc: F[R])(use: R => F[A])(release: R => F[Unit])(implicit F: MonadCancel[F, E]): F[A] =
  F uncancelable { poll =>
    for {
      r <- alloc

      _ <- poll(s.acquire).onCancel(release(r))
      releaseAll = s.release >> release(r)

      a <- poll(use(r)).guarantee(releaseAll)
    } yield a
  }
  
//-----------------
import cats.effect.IO
import cats.effect.unsafe.implicits.global

val run = for {
  fib <- (IO.uncancelable(_ =>
      IO.canceled >> IO.println("This will print as cancelation is suppressed")
    ) >> IO.println(
      "This will never be called as we are canceled as soon as the uncancelable block finishes"
    )).start
  res <- fib.join
} yield res

/** code part 2 section
run.unsafeRunSync()
*/

/* This will print as cancelation is suppressed */

import cats.effect.IO
import cats.effect.unsafe.implicits.global

val run = for {
  fib <- (IO.uncancelable(_ =>
      IO.println("This will print as cancelation is suppressed")
    ) >> IO.println(
      "This will never be called as we are canceled as soon as the uncancelable block finishes"
    )).start
  res <- fib.join
} yield res

/** code part 2 section
run.unsafeRunSync()
*/

/* This will print as cancelation is suppressed
This will never be called as we are canceled as soon as the uncancelable block finishes */


//----------------------------------- Spawn -----------------------------------
// https://typelevel.org/cats-effect/docs/typeclasses/spawn

// showing structure only:
import cats.effect.{MonadCancel, Spawn}
import cats.effect.syntax.all._
import cats.syntax.all._

trait Server[F[_]] {
  def accept: F[Connection[F]]
}

trait Connection[F[_]] {
  def read: F[Array[Byte]]
  def write(bytes: Array[Byte]): F[Unit]
  def close: F[Unit]
}

def endpoint[F[_]: Spawn](
    server: Server[F])(
    body: Array[Byte] => F[Array[Byte]])
    : F[Unit] = {

  def handle(conn: Connection[F]): F[Unit] =
    for {
      request <- conn.read
      response <- body(request)
      _ <- conn.write(response)
    } yield ()

  val handler = MonadCancel[F] uncancelable { poll =>
    poll(server.accept) flatMap { conn =>
      handle(conn).guarantee(conn.close).start
    }
  }
  handler.foreverM
}



//------------------------------ cancel a fiber ------------------------------
import scala.concurrent.duration._
import cats.effect.IO
import cats.effect.unsafe.implicits.global

{
  for {
    target <- IO.println("Catch me if you can!").foreverM.start
    _ <- IO.sleep(1.second)
    _ <- target.cancel
  } yield ()
}.unsafeRunSync()



import cats.syntax.all._
import cats.effect.unsafe.implicits.global

{
  (-10 to 10).toList.parTraverse(i => IO(5f / i))
}.unsafeRunSync()


// don't use this in production; it is a simplified example
def both[F[_]: Spawn, A, B](fa: F[A], fb: F[B]): F[(A, B)] =
  for {
    fiberA <- fa.start
    fiberB <- fb.start

    a <- fiberA.joinWithNever
    b <- fiberB.joinWithNever
  } yield (a, b)


// The joinWithNever function is a convenience method built on top of join, which is much more general. 


Outcome has the following shape:

    Succeeded (containing a value of type F[A])
    Errored (containing a value of type E, usually Throwable)
    Canceled (which contains nothing)

fiber.join flatMap {
  case Outcome.Succeeded(fa) =>
    fa

  case Outcome.Errored(e) => 
    MyWrapper(e).pure[F]

  case Outcome.Canceled() => ???
}

  case Outcome.Canceled() => 
    MonadThrow[F].raiseError(new FiberCanceledException)

  case Outcome.Canceled() => 
    MonadCancel[F].canceled // => F[Unit]

case Outcome.Canceled() => 
  MonadCancel[F].canceled.as(default)


import cats.conversions.all._

fiber.join flatMap {
  case Outcome.Succeeded(fa) => // => F[Some[A]]
    fa.map(Some(_))

  case Outcome.Errored(e) => // => F[Option[A]]
    MonadError[F, E].raiseError(e) 

  case Outcome.Canceled() => // => F[None]
    MonadCancel[F].canceled.as(None)
}


If you are really sure that you're joining and you're never,
ever going to be wrapped in an uncancelable, you can use never to resolve this problem:

fiber.join flatMap {
  case Outcome.Succeeded(fa) => // => F[A]
    fa

  case Outcome.Errored(e) => // => F[A]
    MonadError[F, E].raiseError(e) 

  case Outcome.Canceled() => // => F[A]
    MonadCancel[F].canceled >> Spawn[F].never[A]
}

//---------------------------------- Unique ----------------------------------
// https://typelevel.org/cats-effect/docs/typeclasses/unique

// low-level 

trait Unique[F[_]] {
  def unique: F[Unique.Token]
}

//  If you need globally unique token ..., use a UUID instead

//----------------------------------- Clock -----------------------------------
// https://typelevel.org/cats-effect/docs/typeclasses/clock
// A typeclass that provides effectful monotonic and system time analogous to System.nanoTime() and System.currentTimeMillis()

trait Clock[F[_]] {

  def monotonic: F[FiniteDuration]

  def realTime: F[FiniteDuration]

}


//-------------------------------- Concurrent --------------------------------
// https://typelevel.org/cats-effect/docs/typeclasses/concurrent
// We can memoize an effect so that it's only run once and the result used repeatedly.

// Memoization:

def memoize[A](fa: F[A]): F[F[A]]


// example:

import cats.effect.IO
import cats.effect.unsafe.implicits.global
 
val action: IO[String] = IO.println("This is only printed once!").as("action")

val prog: cats.effect.IO[Tuple3[String, String, String]] = for {
  memoized <- action.memoize
  res1 <- memoized
  res2 <- memoized
  res3 <- memoized
} yield (res1, res2, res3)

prog.unsafeRunSync()

// Ref and Deferred:
// example countdown latch:
sealed trait State[F[_]]
case class Awaiting[F[_]](latches: Int, signal: Deferred[F, Unit]) extends State[F]
case class Done[F[_]]() extends State[F]

def await: F[Unit] =
  state.get.flatMap {
    case Awaiting(_, signal) => signal.get
    case Done() => F.unit
  }
  
def release: F[Unit] =
  F.uncancelable { _ =>
    state.modify {
      case Awaiting(n, signal) =>
        if (n > 1) (Awaiting(n - 1, signal), F.unit) else (Done(), signal.complete(()).void)
      case d @ Done() => (d, F.unit)
    }.flatten
  }

// Concurrency in Cats Effect:
// -> https://typelevel.org/blog/2020/10/30/concurrency-in-ce3.html
// file:///C:\___jvr_work\___workspaces\____scala\_____LEARN\catseffect\catseffect_5_concurrency-in-ce3.scsc

// Writings:
// -> https://systemfw.org/writings.html

//--------------------------------- Temporal ---------------------------------
// https://typelevel.org/cats-effect/docs/typeclasses/temporal









