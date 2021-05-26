:paste

//from:
// https://github.com/scalafx/scalafx/blob/master/scalafx-demos/src/main/scala/scalafx/ColorfulCircles.scala


// package scalafx // packages not allowed in a script

import scala.collection.immutable.VectorBuilder
import scala.language.postfixOps
import scala.math.random
import scalafx.Includes._
import scalafx.animation.Timeline
import scalafx.animation.Timeline.Indefinite
import scalafx.application.JFXApp
import scalafx.application.JFXApp.PrimaryStage
import scalafx.scene.effect.BlendMode.Overlay
import scalafx.scene.effect.BoxBlur
import scalafx.scene.paint.Color.{Black, White}
import scalafx.scene.paint.CycleMethod.NoCycle
import scalafx.scene.paint.{LinearGradient, Stops}
import scalafx.scene.shape.StrokeType.Outside
import scalafx.scene.shape.{Circle, Rectangle}
import scalafx.scene.{Group, Scene}
//import scalafx.event.ActionEvent
//import scalafx.stage.{WindowEvent, StageStyle}


object scalafxTest2 extends JFXApp {
	val circlesToAnimate = new VectorBuilder[Circle]()
	stage = new PrimaryStage {
		title = "ColorfulCircles"
		width = 800
		height = 600
		scene = new Scene {
			_scene =>
			fill = Black
			content = Seq(
				new Group {
					children = Seq(
						new Rectangle {
							width <== _scene.width
							height <== _scene.height
							fill = Black
						},
						new Group {
							val circles = for (_ <- 0 until 15) yield new Circle {
								radius = 200
								fill = White opacity 0.05
								stroke = White opacity 0.2
								strokeWidth = 4
								strokeType = Outside
							}
							children = circles
							circlesToAnimate ++= circles
							effect = new BoxBlur(30, 30, 3)
						},
						new Group {
							val circles = for (_ <- 0 until 20) yield new Circle {
								radius = 70
								fill = White opacity 0.05
								stroke = White opacity 0.1
								strokeWidth = 2
								strokeType = Outside
							}
							children = circles
							circlesToAnimate ++= circles
							effect = new BoxBlur(2, 2, 2)
						},
						new Group {
							val circles = for (_ <- 0 until 10) yield new Circle {
								radius = 150
								fill = White opacity 0.05
								stroke = White opacity 0.16
								strokeWidth = 4
								strokeType = Outside
							}
							children = circles
							circlesToAnimate ++= circles
							effect = new BoxBlur(10, 10, 3)
						})
				},
				new Rectangle {
					width <== _scene.width
					height <== _scene.height
					fill = new LinearGradient(0, 1, 1, 0, true, NoCycle,
						Stops(0xf8bd55, 0xc0fe56, 0x5dfbc1, 0x64c2f8, 0xbe4af7, 0xed5fc2, 0xef504c, 0xf2660f))
					blendMode = Overlay
				}
			)
		}
	}
	val tl = new Timeline {
		cycleCount = Indefinite
		autoReverse = true
		keyFrames = (for (circle <- circlesToAnimate.result()) yield Seq(
			at(0 s) {
				Set(circle.centerX -> random * 800,
					circle.centerY -> random * 600)
			},
			at(40 s) {
				Set(circle.centerX -> random * 800,
					circle.centerY -> random * 600)
			}
		)).flatten
	}
	
	tl.play()
}


scalafxTest2.main(Array("")) // comment out if not script




