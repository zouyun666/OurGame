import Felgo 3.0
import QtQuick 2.0
import "../game"
import "../ui"

SceneBase {
  id: scene

  // the "logical size" - the scene content is auto-scaled to match the GameWindow size
  width: 320
  height: 480

  // signal splash screen finished
  signal splashScreenFinished()

  // show splashscreen
  SplashScreen {
    id: splashScreen
    anchors.fill: parent.gameWindowAnchorItem
    anchors.centerIn: parent.gameWindowAnchorItem

    onSplashScreenFinished: scene.splashScreenFinished()
    //这个是SplashScreen的splashScreenFinished()信号处理器，处理的是发送上面的splashScreenFinished()信号
  }
}
