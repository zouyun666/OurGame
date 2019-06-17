import Felgo 3.0
import QtQuick 2.0

GameWindow {
    id: gameWindow

    activeScene: scene

    screenWidth: 640
    screenHeight: 960

    onSplashScreenFinished: scene.startGame()

    //我们还在createBlock-function中添加我们正在使用的EntityManager组件，并将游戏区域指定为所有块的entityContainer。
    EntityManager {
        id:entityManager
        entityContainer: gameArea   //将游戏区域指定为所有块的entityContainer
    }

    FontLoader {
        id:gameFont
        source: "../assets/fonts/akaDylan Plain.ttf"
    }

    Scene {
       id:scene
       width: 320
       height: 480

       property int score

       BackgroundImage {
           source: "../assets/JuicyBackground.png"
           anchors.centerIn: scene.gameWindowAnchorItem
       }

       Text {
           font.family: gameFont.name
           font.pixelSize: 12
           color: "red"
           text: scene.score

           anchors.horizontalCenter: parent.horizontalCenter
           y:446
       }

       // startGame-function重置点和游戏区域。 每次必须开始新游戏时都会调用它。
       GameArea {
           id:gameArea
           anchors.horizontalCenter: scene.horizontalCenter
           blockSize: 30
           y:20
       }

       function startGame() { //onSplashScreenFinished：scene.startGame（）行将在Felgo启动画面消失后触发第一次初始化。
           gameArea.initializeField()
           scene.score = 0
       }
   }
}
