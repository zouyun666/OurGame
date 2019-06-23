import Felgo 3.0
import QtQuick 2.0

Item {
  id: titleWindow

  width: 304
  height: 263

  visible: opacity > 0
  enabled: opacity == 1

  property int continueclick :0   //continueButton被点击时continueclick的值为1

  signal demoMenuClicked()
  signal continueClicked()
  signal resourcesClicked()

  Image {
    source: "../../assets/img/TitleWindow.png"
    anchors.fill: parent
  }

  // play button
  Text {
    id: playButton
    font.family: gameFont1.name
    font.pixelSize: 20
    color: "red"
    text: "play"

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 70

    MouseArea {
      anchors.fill: parent
      onClicked: {
          demoMenuClicked()
          titleWindow.continueclick= 0
      }
    }

    // 此动画序列无限地更改红色和橙色之间的文本颜色
    SequentialAnimation on color {
      loops: Animation.Infinite
      PropertyAnimation {
        to: "#FA8072"
        duration: 1000
      }
      PropertyAnimation {
        to: "#FF4500"
        duration: 1000
      }
    }
  }


  JuicyButton {
    id: continueButton
    text: "continue game"

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top:parent.bottom
    anchors.topMargin: -10

    onClicked: {
        continueClicked()
        gameData.load();
        if(gameData.demoCount === 1){
            gameArea2.opacity=0
            gameArea3.opacity=0
            gameArea1.opacity=1
            scene.startGame1()
            scene.score = gameData.score

        }
        if(gameData.demoCount === 2){
            gameArea1.opacity=0
            gameArea3.opacity=0
            gameArea2.opacity=1
            scene.startGame2()
            scene.score = gameData.score

        }
        if(gameData.demoCount === 3){
            gameArea2.opacity=0
            gameArea1.opacity=0
            gameArea3.opacity=1
            scene.startGame3()
            scene.score = gameData.score

        }
    }
  }

  JuicyButton {
    text: "resources"

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: continueButton.bottom
    anchors.topMargin: 0
    onClicked: resourcesClicked()
  }

  // 淡出淡入动画
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

  function continueclicks (){
      return 1
  }
}
