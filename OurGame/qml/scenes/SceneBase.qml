import QtQuick 2.0
import Felgo 3.0

// base component for all scenes in the game,//游戏中所有场景的基本组件
Scene {
  id: sceneBase
   //这很重要，因为它作为物理对象质量的参考大小，因为物体的质量取决于其图像的宽度
  width: 320
  height: 480

  opacity: 0
  //注意：在qt5中，默认情况下不透明元素是不可见的，它会处理鼠标和键盘输入！
  //因此也禁用键盘焦点和鼠标处理并使项目不可见，根据不透明度设置可见和启用属性
  visible: opacity === 0 ? false : true
  enabled: visible

  //behavior定义了特定属性值更改时要应用的默认动画。
  Behavior on opacity { NumberAnimation{duration: 250} }

  signal enterPressed

  Keys.onPressed: {
    if(event.key === Qt.Key_Return) {
      enterPressed()
    }
  }

  Keys.onReturnPressed: {
    enterPressed()
  }
}
