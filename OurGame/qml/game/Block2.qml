import QtQuick 2.0
import Felgo 3.0

//EntityBase组件是Felgo游戏中所有游戏实体的基类。 它是游戏逻辑，视觉表示，物理或音频组件的其他组件的容器。 实体与EntityManager一起使用，EntityManager处理实体的创建，删除和接收。EntityBase有两个主要属性：entityType和entityId。

EntityBase {
    id:block
    entityType: "block"

    visible: y >=0//以隐藏将放置在游戏区域之外的新创建的水果。 当动画将动画移动到游戏区域时，它们会自动显示。

    property int type
    property int row
    property int column

    signal clicked(int row, int column, int type)

    Image {
      anchors.fill: parent
      source: {
        if (type == 0)
          return "../../assets/Apple.png"
        else if(type == 1)
          return "../../assets/Banana.png"
        else if (type == 2)
          return "../../assets/Orange.png"
        else if (type == 3)
          return "../../assets/Pear.png"
        else if (type == 4)
          return "../../assets/BlueBerry.png"
        else if (type == 5)
          return "../../assets/Coconut.png"
        else if (type == 6)
          return "../../assets/Lemon.png"
        else
          return "../../assets/WaterMelon.png"
      }
    }
    MouseArea {
      anchors.fill: parent
      onClicked: parent.clicked(row, column, type)
    }

//使用两个NumberAnimations来实现水果的淡出和移动。 在任何块开始移动之前，它应该等待游戏中其他块的淡出。
    NumberAnimation {
        id:fadeOutAnimation
        target: block
        property: "opacity"
        duration: 100
        from: 1.0
        to:0

        onStopped: {
            entityManager.removeEntityById(block.entityId)
        }
    }

    NumberAnimation {
        id:fallDownAnimation
        target: block
        property: "y"
    }

    //使用Timer并将淡出持续时间设置为其间隔。 在那段时间过去之后，我们将开始运动。
    Timer {
        id: fallDownTimer
        interval: fadeOutAnimation.duration
        repeat: false
        running: false
        onTriggered: {
            fallDownAnimation.start()
        }
    }

  //remove-function淡出块并在动画结束时从游戏中移除实体。
    function remove() {
         fadeOutAnimation.start()
    }
//fallDown函数等待一段时间，直到网格中的其他块的移除完成，然后将块向下移动一定距离。
    function fallDown(distance) {
    // complete previous fall before starting a new one
        fallDownAnimation.complete()

        // move with 100 ms per block
        // e.g. moving down 2 blocks takes 200 ms
        fallDownAnimation.duration = 100 *distance
        fallDownAnimation.to=block.y+distance*block.height

        // wait for removal of other blocks before falling down
        fallDownTimer.start()
    }
}
