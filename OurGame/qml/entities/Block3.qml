import Felgo 3.0
import QtQuick 2.0

EntityBase{

    id:block
    entityType: "block"
    visible: y>=0

    property int type
    property int row
    property int column

    property int sumclicks: 0//记录点击次数

    signal clicked(int row, int column, int type)
    signal selection()

    Image{
        anchors.fill: parent
        source: {
            if(type==0)
                return "../../assets/img/fruits/Apple.png"
            else if(type==1)
                return "../../assets/img/fruits/Banana.png"
            else if(type==2)
                return "../../assets/img/fruits/Orange.png"
            else if(type==3)
                return "../../assets/img/fruits/Pear.png"
            else if(type==4)
                return "../../assets/img/fruits/BlueBerry.png"
            else if (type == 5)
              return "../../assets/img/fruits/Coconut.png"
            else if (type == 6)
              return "../../assets/img/fruits/Lemon.png"
            else
              return "../../assets/img/fruits/WaterMelon.png"
        }
    }

    NumberAnimation{
        id: fadeOutAnimation
        target: block
        property: "opacity"
        duration: 100
        from: 1.0
        to: 0

        //淡出完成后删除块
        onStopped:{
entityManager.removeEntityById(block.entityId)
        }
    }

    Rectangle {
      id: highlightRect
      color: "white"
      anchors.fill: parent
      anchors.centerIn: parent
      opacity: 0
      z: 1
    }

    SequentialAnimation {
      id: highlightAnimation
      loops: Animation.Infinite
      NumberAnimation {
        target: highlightRect
        property: "opacity"
        duration: 750
        from: 0
        to: 0.35
      }
      NumberAnimation {
        target: highlightRect
        property: "opacity"
        duration: 750
        from: 0.35
        to: 0
      }
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {

            highlightRect.opacity =1
            highlightAnimation.start()

            sumclicks++
            parent.clicked(row, column, type)

        }
    }
    onSelection:highlightAnimation.stop()
}
