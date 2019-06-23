import Felgo 3.0
import QtQuick 2.0

Item {
  id: gameOverWindow

  width: 232
  height: 160
  visible: opacity > 0//opacity为0时不可见
  enabled: opacity == 1//opacity等于1时接收鼠标键盘事件

  signal demoMenuClicked()
  signal backClicked()//返回信号

  Image {
    source: "../../assets/img/GameOverWindow.png"
    anchors.fill: parent
  }

  //分数显示
  Text {
    font.family: gameFont.name
    font.pixelSize: 30
    color: "#1a1a1a"
    text: scene.score

    anchors.horizontalCenter: parent.horizontalCenter
    y: 72
  }

  // 再玩一次
  Text {
    font.family: gameFont.name
    font.pixelSize: 15
    color: "red"
    text: "play again!"

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 15

    MouseArea {
      anchors.fill: parent
      onClicked: demoMenuClicked()
    }

    // 此动画序列无限地更改红色和橙色之间的文本颜色
    SequentialAnimation on color {
      loops: Animation.Infinite
      PropertyAnimation {
        to: "#ff8800"
        duration: 1000
      }
      PropertyAnimation {
        to: "red"
        duration: 1000
      }
    }
  }

  // 返回按钮
  JuicyButton {
    text: "back to menu"

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.bottom
    anchors.topMargin: 0

    onClicked: backClicked()
  }


  // 淡出淡入动画
  Behavior on opacity {
    NumberAnimation { duration: 400 }
  }

  // 显示gameWindow
  function show() {
    gameOverWindow.opacity = 1
  }

  //隐藏gameWindow
  function hide() {
    gameOverWindow.opacity = 0
  }
}
