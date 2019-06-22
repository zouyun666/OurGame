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
  property int continueclick :0
  // signal when buttons are clicked
//  signal startClicked()
  signal startMenu()
  signal continueClicked()
  signal resourcesClicked()
//  signal vplayClicked()

  Image {
    source: "../../assets/img/TitleWindow.png"
    anchors.fill: parent
  }

  // play button
  Text {
    id: playButton
    // set font
    font.family: gameFont1.name
    font.pixelSize: 20
    color: "red"
    text: "play"

    // set position
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 70

    // signal click event
    MouseArea {
      anchors.fill: parent
      onClicked: {
          startMenu()
          titleWindow.continueclick= 0
      }
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
    id: continueButton
    text: "continue game"

    // set position
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top:parent.bottom
    anchors.topMargin: -10

    onClicked: {
        continueClicked()
        gameData.load();
        if(gameData.demoCount == 1){
            gameArea2.opacity=0
            gameArea3.opacity=0
            gameArea.opacity=1
            scene.startGame()
            scene.score = gameData.score

        }
        if(gameData.demoCount == 2){
            gameArea.opacity=0
            gameArea3.opacity=0
            gameArea2.opacity=1
            scene.startGame2()
            scene.score = gameData.score

        }
        if(gameData.demoCount == 3){
            gameArea2.opacity=0
            gameArea.opacity=0
            gameArea3.opacity=1
            scene.startGame3()
            scene.score = gameData.score

        }
    }
  }

  // credits button
  JuicyButton {
    text: "resources"

    // set position
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: continueButton.bottom
    anchors.topMargin: 0
    onClicked: resourcesClicked()
  }

  // fade in/out animation
  Behavior on opacity {
    NumberAnimation { duration: 400 }
  }

  // shows the window
  function show() {
//      titleWindow.enabled=true
    titleWindow.opacity = 1
  }

  // hides the window
  function hide() {
    titleWindow.opacity = 0
  }

  function continueclicks (){
      return 1
  }
}
