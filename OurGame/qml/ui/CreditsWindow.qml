import Felgo 3.0
import QtQuick 2.0

Item {
  id: creditsWindow

  width: 243
  height: 180

  // hide when opacity = 0
  visible: opacity > 0

  // disable when opacity < 1
  enabled: opacity == 1

//点击新游戏按钮时发出信号
  signal backClicked()
//  signal vplayClicked()

  Image {
    source: "../../assets/img/CreditsWindow.png"
    anchors.fill: parent
  }

  // back button
  JuicyButton {
    text: "back to menu"

    // set position
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.bottom
    anchors.topMargin: 0

    onClicked: backClicked()
  }

  // fade in/out animation
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
