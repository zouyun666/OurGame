import Felgo 3.0
import QtQuick 2.0

Item {
  id: button

  width: 162
  height: 45

  property string text

  // 点击信号
  signal clicked()

  // 背景图片
  Image {
    source: "../../assets/img/ButtonBG.png"
    anchors.fill: parent
  }

  // 设置文本
  Text {
    font.family: gameFont.name
    font.pixelSize: 12
    color: "red"
    text: button.text

    anchors.horizontalCenter: parent.horizontalCenter
    y: 15
  }

  MouseArea {
    anchors.fill: parent
    onClicked: button.clicked()
  }
}
