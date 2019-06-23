import QtQuick 2.0
import Felgo 3.0

////游戏中所有场景的基本组件
Scene{
    id: sceneBase

    width: 320
    height: 480

    opacity: 0//不可见
    visible: opacity === 0 ? false : true//根据不透明度设置可见性
    enabled: visible//此也禁用键盘焦点和鼠标处理

    Behavior on opacity {
        NumberAnimation{duration: 250}
    }

    signal enterPressed()

    Keys.onPressed: {
        if(event.key === Qt.Key_Return)
            enterPressed()
    }
}

