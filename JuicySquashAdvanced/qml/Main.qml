import Felgo 3.0
import QtQuick 2.0
import "scenes"

GameWindow {
  id: gameWindow

  screenWidth: 640
  screenHeight: 960

  // custom font loading of ttf fonts
  FontLoader {
    id: gameFont
    source: "../assets/fonts/akaDylan Plain.ttf"
  }

  // loading screen,加载屏幕
  Rectangle {
    id: loadScreen
    width: gameWindow.width
    height: gameWindow.height
    color: "#FFB6C1"
    z: 1  //默认值为零，即后面的Item在前面的Item之上，若z值较大，则该Item将绘制在上面

    opacity: 0
    enabled: opacity == 1 ? true : false
    visible: opacity > 0 ? true : false

    // signal when load screen is fully visible
    signal fullyVisible()

    // background and text
    Text {
      // set font
      font.family: gameFont.name
      font.pixelSize: gameWindow.width / 640 * 24
      color: "red"
      text: "Loading ..."
      anchors.centerIn: parent
    }

    // animate loading screen
    Behavior on opacity {
      PropertyAnimation {
        duration: 3000
        onRunningChanged: {
          if(!running && opacity == 1) //running此属性保存动画当前是否正在运行。可以将running属性设置为以声明方式控制动画是否正在运行。 以下示例将在按下MouseArea时为矩形设置动画。
            loadScreen.fullyVisible()
        }
      }
    }
  }

  // add spashscreen scene (first scene to show)，启动画面场景
  SplashScreenScene {
    id: splashScene
    onSplashScreenFinished: gameWindow.state = "game" // show game screen after splash screen，启动画面后显示游戏画面
  }

  // use loader to load game-scene when necessary，必要时使用loader来加载游戏场景
  Loader {
    id: gameSceneLoader
    onLoaded: loadScreen.opacity = 0
  }

  // set start state
  state: "splash"

  states: [
    State {
      name: "splash"
      PropertyChanges {target: splashScene; opacity: 1}
      PropertyChanges {target: gameWindow; activeScene: splashScene}
    },
    State {
      name: "game"
      StateChangeScript {
        script: {
          showGameScene()
        }
      }
    }
  ]

  // show game scene
  function showGameScene() {
    // if game scene not loaded -> load first
    if(gameSceneLoader.item === null) {
      gameSceneLoader.loaded.connect(showGameScene)
      loadGameScene()
      return
    }
    //此时肯定会加载场景
    //显示游戏场景
    gameWindow.activeScene = gameSceneLoader.item
    gameSceneLoader.item.opacity = 1
  }

//显示加载屏幕并开始加载游戏场景
  function loadGameScene() {
    loadScreen.opacity = 1
    loadScreen.fullyVisible.connect(fetchAndInitializeGameScene)
  }

//从qml中获取游戏场景并连接信号
  function fetchAndInitializeGameScene() {
    gameSceneLoader.source = "scenes/GameScene.qml"
//    gameSceneLoader.item.highscoreClicked.connect(onHighscoreClicked)
//    gameSceneLoader.item.reportScore.connect(onReportScore)

    loadScreen.fullyVisible.disconnect(fetchAndInitializeGameScene) //断开连接
  }

}
