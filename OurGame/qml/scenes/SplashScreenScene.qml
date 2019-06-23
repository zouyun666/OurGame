import QtQuick 2.0
import Felgo 3.0
import "../entities"
import "../ui"

SceneBase{
    id: scene

    width: 320
    height: 480

    signal splashScreenFinished()//splsh加载完成之后发送这个信号

    //show splashscreen
    SplashScreen{
        id: splashScreen
        anchors.fill: parent.gameWindowAnchorItem
        anchors.centerIn: parent.gameWindowAnchorItem

        onSplashScreenFinished:scene.splashScreenFinished()//这个是SplashScreen的splashScreenFinished()信号处理器，处理的是发送上面的splashScreenFinished()信号

    }
}
