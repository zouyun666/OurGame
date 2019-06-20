import Felgo 3.0
import QtQuick 2.0
import QtMultimedia 5.0

Item {
  id: overlays

  scale: 0.25  //此属性包含此项目的比例因子。小于1.0的比例会导致项目以较小的尺寸呈现，而大于1.0的比例会使项目的尺寸更大。 负标度会导致项目在渲染时被镜像。

  anchors.horizontalCenter: parent.horizontalCenter

  property string textsImgPath: "../../assets/img/texts/"

  // signal when overloadText disappeared
  signal overloadTextDisappeared()

  // configure overlays
  TextOverlay {
    id: fruityText
    anchors.horizontalCenter: parent.horizontalCenter
    imageSource: textsImgPath+"Fruity.png"
  }

  TextOverlay {
    id: sweetText
    anchors.horizontalCenter: parent.horizontalCenter
    imageSource: textsImgPath+"Sweet.png"
  }

  TextOverlay {
    id: refreshingText
    anchors.horizontalCenter: parent.horizontalCenter
    imageSource: textsImgPath+"Refreshing.png"
  }

  TextOverlay {
    id: yummyText
    anchors.horizontalCenter: parent.horizontalCenter
    imageSource: textsImgPath+"Yummy.png"
  }

  TextOverlay {
    id: overloadText
    anchors.horizontalCenter: parent.horizontalCenter
    imageSource: textsImgPath+"JuicyOverload.png"
    animationDuration: 1000
    defaultY: -150
    onOverlayDisappeared: {
      overloadTextDisappeared()
    }
  }

  TextOverlay {
    id: deliciousText
    anchors.horizontalCenter: parent.horizontalCenter
    imageSource: textsImgPath+"Delicious.png"
    animationDuration: 1000
  }

  TextOverlay {
    id: smoothText
    anchors.horizontalCenter: parent.horizontalCenter
    imageSource: textsImgPath+"Smooth.png"
    animationDuration: 1000
  }

  function showFruity() { fruityText.show(); scene.gameSound.playFruitySound() }
  function showSweet() { sweetText.show(); scene.gameSound.playSweetSound() }
  function showRefreshing() { refreshingText.show(); scene.gameSound.playRefreshingSound() }
  function showOverload() { overloadText.show(); scene.gameSound.playOverloadSound() }
  function showYummy() { yummyText.show(); scene.gameSound.playYummySound() }
  function showDelicious() { deliciousText.show(); scene.gameSound.playDeliciousSound() }
  function showSmooth() { smoothText.show(); scene.gameSound.playSmoothSound() }
}
