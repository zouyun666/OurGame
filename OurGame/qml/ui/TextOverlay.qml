import Felgo 3.0
import QtQuick 2.0

Item {
  id: textOverlay//文字叠加

  // 完全隐藏，如果不可见
  visible: opacity > 0
  enabled: opacity > 0

  // 叠加最初是隐藏的
  opacity: 0

  property alias imageSource: image.source      //// 可以为每个覆盖设置图像源

  property int animationDuration: 500

  property int defaultY: 0

  signal overlayDisappeared()     // 信号动画结束了

  Image {
    id: image
    anchors.horizontalCenter: parent.horizontalCenter
  }

  // 动画显示叠加
  ParallelAnimation {
    id: showAnimation

    NumberAnimation {
      target: textOverlay
      property: "scale"
      from: 0.75
      to: 1.25
      duration: animationDuration
    }
    NumberAnimation {
      target: textOverlay
      property: "y"
      from: defaultY + 50
      to: defaultY - 50
      duration: animationDuration
    }
    SequentialAnimation {
      NumberAnimation {
        target: textOverlay
        property: "opacity"
        from: 1
        to: 1
        duration: animationDuration * 0.75
      }
      NumberAnimation {
        target: textOverlay
        property: "opacity"
        from: 1
        to: 0
        duration: animationDuration * 0.25
      }
    }
    //ParallelAnimation组件有stopped信号
    onStopped: {
      overlayDisappeared()
    }
  }

  // trigger animation
  function show() {
    showAnimation.start()
  }
}
