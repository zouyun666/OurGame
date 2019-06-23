import QtQuick 2.0

Item {
    id: splashScreen
    z:1000

    property int duration: 5000
    signal splashScreenFinished()

    Rectangle{
        id: splashImage
        anchors.fill: parent

        //设置渐变色
        gradient: Gradient {
            GradientStop {position: 0.00;color: "#fed6e3";}
            GradientStop {position: 1.00;color: "#a8edea";}
        }

        Column{
            id: splashColumn
            anchors.centerIn: parent
            spacing: 10
            Image{
                fillMode: Image.PreserveAspectFit//Image.PreserveAspectFit - 图像均匀缩放以适合而不进行裁剪

                width: splashScreen.width*0.6
                source: "../../assets/img/login_ui.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text{
                color: "#96CDCD"
                text: "Developed by OurGameTeam"
                font.family: gameFont1.name
                font.pixelSize: splashScreen.height*0.04
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text{
                color: "#7AC5CD"
                text: "  g      t  "
                font.family: gameFont1.name
                font.pixelSize: splashScreen.height*0.02
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text{
                color: "#7AC5CD"
                text: "  z      y  "
                font.family: gameFont1.name
                font.pixelSize: splashScreen.height*0.02
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
              color: "#7AC5CD"
              text: "  u   i   n  "
              font.family: gameFont1.name
              font.pixelSize: splashScreen.height*0.02 //splashScreen.height*0.0185
              anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
              color: "#7AC5CD"  //7AC5CD
              text: "https://www.github.com/zouyun666/OurGame"
              font.family: gameFont1.name
              font.pixelSize: splashScreen.height*0.02 //splashScreen.height*0.0185
              anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Timer{
            interval: splashScreen.duration//我们logo的显示时间
            running: true
            onTriggered: splashImage.opacity = 0
        }

        Behavior on opacity {
            NumberAnimation{duration: 300}
        }

        onOpacityChanged: {
            if(opacity === 0){
                splashScreen.splashScreenFinished()
                splashImage.visible = false
            }
        }
    }
}


























