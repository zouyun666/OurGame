import Felgo 3.0
import QtQuick 2.0

Item {
  id: splashScreen

  z: 1000

  property int duration: 5000

  signal splashScreenFinished()

  Rectangle {
    id: splashImage
    anchors.fill: parent

    //渐变由两种或更多种颜色定义，这些颜色将无缝混合。
   //颜色被指定为一组GradientStop子项，每个子项定义渐变上从0.0到1.0的位置和颜色。 每个GradientStop的位置通过设置其position属性来定义; 它的颜色是使用其颜色属性定义的。
    //没有任何渐变停止的渐变将呈现为纯白色填充。
    //请注意，此项目不是渐变的直观表示。 要显示渐变，请使用支持使用渐变的可视项（如Rectangle）。
    gradient: Gradient {
        GradientStop {
            position: 0.00;
            color: "#ffb6c1";
        }
        GradientStop {
            position: 1.00;
            color: "#ff69b4";
        }
    }

    Column {
      id: splashColumn
      anchors.centerIn: parent
      spacing: 10
      Image {
        fillMode: Image.PreserveAspectFit  //Image.PreserveAspectFit - 图像均匀缩放以适合而不进行裁剪
        width: splashScreen.width * 0.5
        source: "../../assets/img/logo.jpg"

        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        color: "white"
        text: "Powered by Felgo"
        font.pixelSize: splashScreen.height*0.02
        anchors.horizontalCenter: parent.horizontalCenter
      }
      Text {
        color: "white"
        text: "www.felgo.com"
        font.pixelSize: splashScreen.height*0.0185
        anchors.horizontalCenter: parent.horizontalCenter
      }
    }

    visible: true

    z: 1 // put on top of all others here

    Timer {
        //飞溅将显示多长时间
        //使它4秒（从最初的5秒减少）
      interval: splashScreen.duration  //设置触发器之间的间隔，以毫秒为单位。默认时间间隔为1000毫秒。
      running: true
      onTriggered: {
        splashImage.opacity = 0
      }
    }

    Behavior on opacity {
      NumberAnimation {
        duration:300 //   更快的褪色，使其看起来更高效
      }
    }

    onOpacityChanged: {
      if(opacity === 0) {
        splashScreen.splashScreenFinished()
        splashImage.visible = false
      }
    }
  }// Splash
} // item
