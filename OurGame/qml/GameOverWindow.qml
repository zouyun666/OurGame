import QtQuick 2.0
import Felgo 3.0

Item {
    id: gameOverWindow

    width: 232
    height: 160


    // hide when opacity = 0,仅在窗口完全可见时单击按钮才启用交互。
    visible: opacity>0
    // disable when opacity < 1 ,此属性保存项目是否接收鼠标和键盘事件。默认情况下这是真的。
    enabled: opacity == 1 //完全不透明

    signal newGameClicked()

    Image {
        source: "../assets/GameOver.png"
        anchors.fill: parent
    }

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
      text: "play again"

      // set position
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 15

      // signal click event
      MouseArea {
        anchors.fill: parent
        onClicked: gameOverWindow.newGameClicked()
      }

      // this animation sequence changes the color of text between red and orange infinitely,SequentialAnimation和ParallelAnimation类型允许多个动画一起运行。 SequentialAnimation中定义的动画是一个接一个地运行，而ParallelAnimation中定义的动画是同时运行的。
      SequentialAnimation on color {
        loops: Animation.Infinite  //如果设置为Animation.Infinite，动画将不断重复，直到它被显式停止 - 通过将running属性设置为false，或者通过调用stop（）方法。
        PropertyAnimation {//PropertyAnimation提供了一种为属性值的更改设置动画的方法。
          to: "#ff8800"
          duration: 1000 // 1 second for fade to orange
        }
        PropertyAnimation {
          to: "red"
          duration: 1000 // 1 second for fade to red
        }
      }
    }

    Behavior on opacity {
        NumberAnimation{duration: 400}
    }

    function show() {
        gameOverWindow.opacity = 1
    }

    function hide() {
        gameOverWindow.opacity = 0
    }

}
