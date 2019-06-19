import Felgo 3.0
import QtQuick 2.0

Item {
  id: juicyMeter
  property double percentage
  property string color1: "#ffff00"
  property string color2: "#ffaa00"

  signal juicyMeterFull()
  signal juicyMeterEmpty()

  Behavior on percentage {
    NumberAnimation {
      duration: 1000
    }
  }

  onPercentageChanged: { //自定义一个属性，会隐式地为该属性创建一个值改变信号，以及一个相应的信号处理器
    if(percentage <= 0)
      juicyMeterEmpty()
    else if(percentage >= 100) {
      juicyMeterFull()
    }
  }

  Rectangle {
    id: juicyMeterBorder
    width: juicyMeterBG.width + 2
    height: juicyMeterBG.height + 4
    anchors.centerIn: juicyMeterBG
    color: "white"
  }

  Rectangle {
    id: juicyMeterBG
    width:  parent.width
    height: parent.height
    anchors.centerIn: parent
    color: "#cccccc"
  }

  Rectangle {
    id: juicyMeterLevel
    width: juicyMeterBG.width
    height: juicyMeterBG.height * (juicyMeter.percentage / 100)
    anchors.horizontalCenter: juicyMeterBG.horizontalCenter
    anchors.bottom: juicyMeterBG.bottom
    color: juicyMeter.color2
  }

  // juciy meter animation
  SequentialAnimation {
    id: juicyMeterAnimation
    running: true

    loops: Animation.Infinite  //此属性保存动画应播放的次数。默认情况下，循环为1：动画将播放一次然后停止。如果设置为Animation.Infinite，动画将不断重复，直到它被显式停止 - 通过将running属性设置为false，或者通过调用stop（）方法。

    PropertyAnimation {
      target: juicyMeterLevel
      property: "color"
      from: juicyMeter.color1
      to: juicyMeter.color2
      duration: 1000
    }
    PropertyAnimation {
      target: juicyMeterLevel
      property: "color"
      duration: 1000
      from: juicyMeter.color2
      to: juicyMeter.color1
    }
  }
}
