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

//    property bool isSelected: false
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

//    Item {
//      id: particleItem
//      width: parent.width
//      height: parent.height
//      x: parent.width/2
//      y: parent.height/2

//      //粒子元素总是由粒子系统在内部管理，不能在QML中创建。 然而，有时它们通过信号暴露，以允许任意改变粒子状态
//      Particle {
//        id: sparkleParticle
//        fileName: "../particles/FruitySparkle.json"
//      }
//      opacity: 0
//      visible: opacity > 0
//      enabled: opacity > 0
//    }

    MouseArea{
        anchors.fill: parent
        onClicked: {
            console.log("CLicked")
//            isSelected=true
//            console.log(isSelected)

            sumclicks++
//            console.log(sumclicks)

            parent.clicked(row, column, type)
//            parent.selection(row, column, type, sumclicks);
//            block.remove()
    }
}
}
