import Felgo 3.0
import QtQuick 2.0
import "./scenes"

GameWindow {
    id: gameWindow

    screenWidth: 640
    screenHeight: 960



    // 设置字体
    FontLoader{
        id: gameFont
        source: "../assets/fonts/akaDylan Plain.ttf"
    }

    FontLoader{
        id: gameFont1
        source: "../assets/fonts/Flower Bold.ttf"
    }

    SplashScreenScene{
        id: splashScene
        onSplashScreenFinished: gameWindow.state = "game"//启动画面后显示游戏画面
    }

    //loading 屏幕的加载
    Rectangle{
        id: loadScreen
        width: gameWindow.width
        height: gameWindow.height

        signal fullyVisible()//当loading加载完成后发送此信号

        color: "#FFB6C1"
        z:1 //默认值为0,即后面的Item在前面的Item之上，z值大的在z值小的上面

        opacity: 0
        enabled: opacity == 1 ? true : false//将是否接收鼠标事件与opacity相绑定
        visible: opacity > 0 ? true : false//将可见性与opacity相绑定

        gradient: Gradient{
            GradientStop{position: 0.00; color:"#fed6e3"}
            GradientStop{position: 1.00;color: "#a8edea"
        }//设置渐变色
    }

        Text{
            font.family: gameFont1.name
            font.pixelSize: gameWindow.width/640*24
            color: "red"
            text: "Loading..."
            anchors.centerIn: parent
        }

        //加载的动画
        Behavior on opacity {
            PropertyAnimation{
                duration: 3000
                onRunningChanged: {
                    if(!running && opacity == 1)////running此属性保存动画当前是否正在运行。
                        loadScreen.fullyVisible()//加载的动画执行完后发送这个信号
                }
            }
        }
    }

    //加载游戏场景
    Loader{
        id:gameSceneLoader
        onLoaded:loadScreen.opacity = 0
    }

    state: "splash"

    states: [
        State {
            name: "splash"
            PropertyChanges{target: splashScene;opacity:1}
            PropertyChanges{target:gameWindow;activeScene:splashScene}
        },

        State {
            name: "game"
            StateChangeScript{
                script: showGameScene()
            }
        }
    ]
    function showGameScene(){
        if(gameSceneLoader.item === null){
            gameSceneLoader.loaded.connect(showGameScene)
            loadGameScene()
            return
        }
        //此时肯定会加载场景
        //显示游戏场景
        gameWindow.activeScene = gameSceneLoader.item
        gameSceneLoader.item.opacity = 1
    }

    //显示loading屏幕，并且开始加载游戏场景
    function loadGameScene(){
        loadScreen.opacity = 1
        loadScreen.fullyVisible.connect(fetchAndInitializeGameScene)
    }

    //从qml中获取游戏场景并连接信号
    function fetchAndInitializeGameScene(){
        gameSceneLoader.source = "scenes/GameScene.qml"
        loadScreen.fullyVisible.disconnect(fetchAndInitializeGameScene)
    }
}




















