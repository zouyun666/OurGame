import QtQuick 2.0
import Felgo 3.0

//EntityBase组件是Felgo游戏中所有游戏实体的基类。 它是游戏逻辑，视觉表示，物理或音频组件的其他组件的容器。 实体与EntityManager一起使用，EntityManager处理实体的创建，删除和接收。EntityBase有两个主要属性：entityType和entityId。

EntityBase {
    id:block
    entityType: "block"

    property int type
    property int row
    property int column

    signal clicked(int row, int column, int type)

    Image {
      anchors.fill: parent
      source: {
        if (type == 0)
          return "../assets/Apple.png"
        else if(type == 1)
          return "../assets/Banana.png"
        else if (type == 2)
          return "../assets/Orange.png"
        else if (type == 3)
          return "../assets/Pear.png"
        else
          return "../assets/BlueBerry.png"
      }
    }
    MouseArea {
      anchors.fill: parent
      onClicked: parent.clicked(row, column, type)
    }
}
