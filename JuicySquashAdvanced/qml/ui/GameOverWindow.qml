import Felgo 3.0
import QtQuick 2.0

Item {
  id: gameOverWindow

  width: 232
  height: 160

  // hide when opacity = 0
  visible: opacity > 0

  // disable when opacity < 1
  enabled: opacity == 1

  // signal when new game button is clicked
  signal newGameClicked()
  signal backClicked()

  Image {
    source: "../../assets/img/GameOverWindow.png"
    anchors.fill: parent
  }

  // display score
  Text {
    // set font
    font.family: gameFont.name
    font.pixelSize: 30
    color: "#1a1a1a"
    text: scene.score

    // set position
    anchors.horizontalCenter: parent.horizontalCenter
    y: 72
  }

  // play again button
  Text {
    // set font
    font.family: gameFont.name
    font.pixelSize: 15
    color: "red"
    text: "play again!"

    // set position
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 15

    // signal click event
    MouseArea {
      anchors.fill: parent
      onClicked: newGameClicked()
    }

    // this animation sequence changes the color of text between red and orange infinitely
    SequentialAnimation on color {
      loops: Animation.Infinite
      PropertyAnimation {
        to: "#ff8800"
        duration: 1000 // 1 second for fade to orange
      }
      PropertyAnimation {
        to: "red"
        duration: 1000 // 1 second for fade to red
      }
    }
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
    gameOverWindow.opacity = 1
  }

  // hides the window
  function hide() {
    gameOverWindow.opacity = 0
  }
}
