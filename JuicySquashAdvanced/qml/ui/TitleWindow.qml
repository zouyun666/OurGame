import Felgo 3.0
import QtQuick 2.0

Item {
  id: titleWindow

  width: 304
  height: 263

  // hide when opacity = 0
  visible: opacity > 0

  // disable when opacity < 1
  enabled: opacity == 1

  // signal when buttons are clicked
  signal startClicked()
  signal highscoreClicked()
  signal creditsClicked()
//  signal vplayClicked()

  Image {
    source: "../../assets/img/TitleWindow.png"
    anchors.fill: parent
  }

  // play button
  Text {
    id: playButton
    // set font
    font.family: gameFont.name
    font.pixelSize: 20
    color: "red"
    text: "play!"

    // set position
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 70

    // signal click event
    MouseArea {
      anchors.fill: parent
      onClicked: startClicked()
    }

    // 此动画序列无限地更改红色和橙色之间的文本颜色
    SequentialAnimation on color {
      loops: Animation.Infinite
      PropertyAnimation {
        to: "#FA8072"
        duration: 1000 // 1 second for fade to orange
      }
      PropertyAnimation {
        to: "#FF4500"
        duration: 1000 // 1 second for fade to red
      }
    }
  }

  // highscore score button
  JuicyButton {
    id: highscoreButton
    text: "show highscore"

    // set position
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.bottom
    anchors.topMargin: -10

    onClicked: highscoreClicked()
  }

  // credits button
  JuicyButton {
    text: "credits"

    // set position
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: highscoreButton.bottom
    anchors.topMargin: 0
    onClicked: creditsClicked()
  }

  // fade in/out animation
  Behavior on opacity {
    NumberAnimation { duration: 400 }
  }

  // shows the window
  function show() {
    titleWindow.opacity = 1
  }

  // hides the window
  function hide() {
    titleWindow.opacity = 0
  }
}
