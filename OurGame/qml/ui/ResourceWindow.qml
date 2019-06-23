import Felgo 3.0
import QtQuick 2.0

Item {
  id: creditsWindow

  width: 243
  height: 180
  visible: opacity > 0
  enabled: opacity == 1

  signal backClicked()//点击新游戏按钮时发出信号

  Image {
    source: "../../assets/img/CreditsWindow.png"
    anchors.fill: parent
  }

  JuicyButton {
    text: "back to menu"

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.bottom
    anchors.topMargin: 0

    onClicked: backClicked()
  }

  Behavior on opacity {
    NumberAnimation { duration: 400 }
  }

  // shows the window
  function show() {
    creditsWindow.opacity = 1
  }

  // hides the window
  function hide() {
    creditsWindow.opacity = 0
  }
}
