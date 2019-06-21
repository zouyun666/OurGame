import QtQuick 2.0

Item {
    id:demoMenu
//    width: 640
//    height: 960

    visible: opacity>0
    enabled: opacity==1

    signal startClicked()
    signal startClicked2()
    Image {
        source: "../../assets/img/JuicyBackground.png"
        anchors.fill: parent
        width: 640
        height: 960
    }

    Image {
        y:6
        source: "../../assets/img/ButtonBG.png"
        anchors.horizontalCenter: parent.horizontalCenter
//        anchors.fill: parent
        width: 140
        height:55
        Text {
            font.family: gameFont.name
            font.pixelSize: 15
            color: "red"
            text: "Demo Menu"
            anchors.centerIn: parent
        }
    }
    Image {
        source: "../../assets/img/ButtonBG.png"
        width: 70
        height: 70
        x:60
        y:70
        Text {
            font.family: gameFont.name
            font.pixelSize: 13
            color: "red"
            text: "Demo 1"
            anchors.centerIn: parent

        }
        MouseArea {
            anchors.fill: parent
            onClicked: startClicked()
        }
    }

    Image {
        source: "../../assets/img/ButtonBG.png"
        width: 70
        height:70
        x:190
        y:70
        Text {
            font.family: gameFont.name
            font.pixelSize: 13
            color: "red"
            text: "Demo 2"
            anchors.centerIn: parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked: startClicked2()
        }
    }

    Behavior on opacity {
      NumberAnimation { duration: 400 }
    }

    function show() {
        demoMenu.opacity = 1
    }
    function hide() {
        demoMenu.opacity = 0
    }
}

