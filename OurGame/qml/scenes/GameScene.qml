import Felgo 3.0
import QtQuick 2.0
import GameDataType 1.0
import "../game"
import "../ui"

SceneBase {
  id: scene

//“逻辑大小” - 场景内容自动缩放以匹配GameWindow大小
  width: 320
  height: 480

  // property to hold game score
  property int score

  property  int  clicks:0

  // property to 保持多汁米百分比
  property double juicyMeterPercentage

  // property to hold 剩下的比赛时间
  property int remainingTime

  // 随处显示文本
  property alias overlayText: overlays
  property alias gameSound: gameSoundItem

  // signal for opening highscore
  signal continueClicked()

  // signal for reporting highscore
  signal reportScore(int score)

  //对本机后退按钮做出反应
  onBackButtonPressed: backPressed()

  GameData{
      id:gameData
  }

  // 添加实体管理器
  EntityManager {
    id: entityManager

    entityContainer: gameArea  //这是一个必需属性，指定哪个QML项是使用EntityManager创建的实体的父项。 通常，这将是Scene项。

    poolingEnabled: true //允许实体池，实体不会从内存中删除，但稍后再使用。实体池意味着当您调用removeEntityById（）或EntityBase :: removeEntity（）时，实体不会从内存中删除，但稍后将用于实体并将其设置为不可见。 默认情况下，池已禁用。 但是，强烈建议您使用实体池，尤其是在游戏中动态创建和删除许多实体时。

    //此属性需要输入应动态加载的所有实体
    //这里添加的实体也是可以使用createEntityFromEntityTypeAndVariationType（）创建的实体。实体的组件数组和应该可以使用createEntityFromEntityTypeAndVariationType（）创建的实体的URL。 这意味着可以通过提供entityType和可选的variationType来创建此处添加的所有实体。
    //注意：重要的是此列表中添加的组件永远不会被删除，否则将无法再访问该组件。 因此，请确保不要销毁放置组件定义的qml文件！
    dynamicCreationEntityList: [
      Qt.resolvedUrl("../game/Block.qml")
    ]
  }

  EntityManager {
    id: entityManager2
    entityContainer: gameArea2
    poolingEnabled: true
    dynamicCreationEntityList: [
        Qt.resolvedUrl("../game/Block2.qml")
    ]
  }

  EntityManager {
    id: entityManager3
    entityContainer: gameArea3
    poolingEnabled: true
    dynamicCreationEntityList: [
        Qt.resolvedUrl("../game/Block3.qml")
    ]
  }

  // background image
  BackgroundImage {
    source: "../../assets/img/JuicyBackground.png"
    anchors.centerIn: scene.gameWindowAnchorItem
  }

  // background music
  BackgroundMusic {
    source: "../../assets/snd/POL-coconut-land-short.wav"
    autoPlay: true  //设置此属性可在加载此项目时自动播放背景音乐，例如 在申请开始时。默认情况下，它设置为true。 因此，当settings.musicEnabled属性也设置为true时，将在初始化Settings对象后播放音乐。
  }

  // 保持游戏的声音
  GameSound {
    id: gameSoundItem
  }

  // juicy meter
  JuicyMeter {
    percentage: scene.juicyMeterPercentage
    anchors.centerIn: gameArea
    width: gameArea.width+36
    height: gameArea.height
    onJuicyMeterFull: {
      overlays.showOverload()
      whiteScreen.flash()
    }
  }

//添加空网格
  Image {
    id: grid
    source: "../../assets/img/Grid.png"
    width: 258
    height: 378
    anchors.horizontalCenter: scene.horizontalCenter
    anchors.bottom: scene.bottom
    anchors.bottomMargin: 92
  }

  // add full grid
  Image {
    id: filledGrid
    source: "../../assets/img/GridFull.png"
    width: 258
    height: 378
    anchors.horizontalCenter: scene.horizontalCenter
    anchors.bottom: scene.bottom
    anchors.bottomMargin: 92
    opacity: 1
    Behavior on opacity {
      PropertyAnimation { duration: 500 }
    }
  }

//游戏区域用块保存游戏区域
  GameArea {
    id: gameArea
    anchors.horizontalCenter: scene.horizontalCenter
    anchors.verticalCenter: grid.verticalCenter
    blockSize: 30

    // handle game over
    onGameOver: { currentGameEnded() }

//在新游戏初始化完成后显示游戏区域
    onInitFinished: {
      whiteScreen.stopLoading()
        if(scene.clicks===1){
            scene.score = gameData.score
            scene.remainingTime = gameData.remainedTime
            scene.clicks =0
        }
        else{
           scene.score = 0
            scene.remainingTime = 120
        }
 // 120 seconds
      filledGrid.opacity = 0
      gameTimer.start()
    }

    // 在标题画面上隐藏游戏区域
    opacity: filledGrid.opacity == 1 ? 0 : 1
  }

  GameArea2 {
      id:gameArea2
      anchors.horizontalCenter: scene.horizontalCenter
      anchors.verticalCenter: grid.verticalCenter
      blockSize: 30

      onGameOver: {currentGame2Ended()}

      onInitFinished2: {
          whiteScreen.stopLoading()
//          scene.score = 0;
          if(scene.clicks===1){
              scene.score = gameData.score
              scene.remainingTime = gameData.remainedTime
              scene.clicks =0
          }
          else{
             scene.score = 0
              scene.remainingTime = 120
          }
          scene.juicyMeterPercentage = 0
          filledGrid.opacity = 0
          gameTimer.start()
      }
      // 在标题画面上隐藏游戏区域
      opacity: filledGrid.opacity == 1 ? 0 : 1
  }

  GameArea3 {
      id:gameArea3
      anchors.horizontalCenter: scene.horizontalCenter
      anchors.verticalCenter: grid.verticalCenter
      blockSize: 30

      onGameOver: {currentGame3Ended()}

      onInitFinished3: {
          whiteScreen.stopLoading()
//          scene.score = 0;
          if(scene.clicks===1){
              scene.score = gameData.score
              scene.remainingTime = gameData.remainedTime
              scene.clicks =0
          }
          else{
             scene.score = 0
              scene.remainingTime = 120
          }
          scene.juicyMeterPercentage = 0
          filledGrid.opacity = 0
          gameTimer.start()
      }

      // 在标题画面上隐藏游戏区域
      opacity: filledGrid.opacity == 1 ? 0 : 1
  }

  // show logo
  Image {
    id: juicyLogo
    source: "../../assets/img/JuicySquashLogo.png"
    width: 119
    height: 59
    anchors.horizontalCenter: scene.horizontalCenter
    anchors.bottom: scene.bottom
    anchors.bottomMargin: 35
  }

  // display score
  Text {
    // set font
    font.family: gameFont.name
    font.pixelSize: 12
    color: "red"
    text: scene.score

    // set position
    anchors.horizontalCenter: parent.horizontalCenter
    y: 446

    MouseArea {
      anchors.centerIn: parent
      width: 150
      height: parent.height + 5
      onClicked: highscoreClicked()
    }
  }

  // display remaining time
  Image {
    width: 80
    height: 46
    source: "../../assets/img/TimeLeft.png"

    anchors.right: scene.gameWindowAnchorItem.right
    anchors.top: juicyLogo.top
    anchors.topMargin: juicyLogo.height / 2

    Text {
      font.family: gameFont.name
      font.pixelSize: 12
      color: "red"
      text: remainingTime + " s"

      y: 25
      x: 15
      width: 80 - 15
      horizontalAlignment: Text.AlignHCenter  //设置文本项宽度和高度内文本的水平和垂直对齐方式。默认情况下，文本垂直对齐顶部。
    }

    enabled: opacity == 1
    visible: opacity > 0
    opacity: filledGrid.opacity > 0.5 ? 0 : 1

    Behavior on opacity {
      PropertyAnimation { duration: 200 }
    }
  }

//剩余时间的游戏计时器
  Timer {
    id: gameTimer
    repeat: true
    interval: 1000 // trigger every second
    onTriggered: {
      if(scene.remainingTime > 0){
        scene.remainingTime--
        gameData.remainedTime =scene.remainingTime
        gameData.save()
      }
      else if(!gameArea.fieldLocked) {
        currentGameEnded()
      }
    }
  }

  // 配置标题窗口
  TitleWindow {
    id: titleWindow
    y: 25
    opacity: 1
    anchors.horizontalCenter: scene.horizontalCenter
    onStartMenu: scene.startJuicy()
    onContinueClicked: scene.continueClicked()
    onResourcesClicked: {
      titleWindow.hide();
      creditsWindow.show()
    }
   }

    onContinueClicked: {
        scene.clicks = titleWindow.continueclicks()
    }
  DemoMenuWindow {
      id:demoMenuWindow
      opacity: 0
      anchors.fill: parent
      onStartClicked: {
          gameArea2.opacity=0
          gameArea3.opacity=0
          gameArea.opacity=1
          scene.startGame()
          gameData.demoCount = 1
          gameData.save()

      }
      onStartClicked2: {
          gameArea.opacity=0
          gameArea3.opacity=0
          gameArea2.opacity=1
          scene.startGame2()
          gameData.demoCount = 2
          gameData.save()
      }
      onStartClicked3: {
          gameArea.opacity=0
          gameArea2.opacity=0
          gameArea3.opacity=1
          scene.startGame3()
          gameData.demoCount = 3
          gameData.save()
      }
  }

//配置gameover窗口
  GameOverWindow {
    id: gameOverWindow
    y: 90
    opacity: 0//默认情况下，窗口是隐藏的
    anchors.horizontalCenter: scene.horizontalCenter
    onDemoMenuClicked: backdemoMenu()
    onBackClicked: { openTitleWindow() }
  }

    //配置信用窗口
  CreditsWindow {
    id: creditsWindow
    y: 90
    opacity: 0
    anchors.horizontalCenter: scene.horizontalCenter
    onBackClicked: { openTitleWindow() }
//    }
  }



  //配置主页按钮
  Image {
    width: 52
    height: 45
    source: "../../assets/img/HomeButton.png"

    MouseArea {
      anchors.fill: parent
//      onClicked:  openTitleWindow()  //未实现？？？？
      onClicked:  backPressed()
    }

    x: 5
    y: 432

    visible: opacity > 0
    enabled: opacity == 1
    opacity: titleWindow.opacity > 0.5 ? 0 : 1

    Behavior on opacity {
      PropertyAnimation { duration: 200 }
    }
  }

  //用于闪烁屏幕的矩形
  Rectangle {
    id: whiteScreen
    anchors.fill: gameArea
    anchors.centerIn: gameArea
    color: "#FFC0CB"
    opacity: 0
    visible: opacity > 0
    enabled: opacity > 0

    SequentialAnimation {
      id: flashAnimation
      NumberAnimation {
        target: whiteScreen
        property: "opacity"
        to: 1
        duration: 300
      }
      NumberAnimation {
        target: whiteScreen
        property: "opacity"
        from: 1
        to: 0
        duration: 300
      }
    }

    SequentialAnimation {
      id: loadingAnimation
      loops: Animation.Infinite
      NumberAnimation {
        target: whiteScreen
        property: "opacity"
        to: 1
        duration: 400
      }
      NumberAnimation {
        target: whiteScreen
        property: "opacity"
        from: 1
        to: 0
        duration: 500
      }
    }

    Text {
      id: loadingText

      // set font
      font.family: gameFont.name
      font.pixelSize: 12
      color: "red"
      text: "preparing fruits"

      anchors.centerIn: parent
      opacity: 0

      Behavior on opacity {
        PropertyAnimation { duration: 400 }
      }
    }

    function flash() {
      loadingText.opacity = 0
      loadingAnimation.stop()
      flashAnimation.stop()
      flashAnimation.start()
    }

    function startLoading() {
      loadingAnimation.start()
      loadingText.opacity = 1
    }

    function stopLoading() {
      flash()
    }
  }

  // overlay texts
  Overlays {
    id: overlays
    y: 190
    //超载文本消失
    onOverloadTextDisappeared: {
      scene.juicyMeterPercentage = 0
      gameTimer.stop()
      gameArea.removeAllBlocks()
      whiteScreen.flash()
      scene.remainingTime += 60
      gameTimer.start()
    }
  }

  //点击播放后的初始化计时器
  Timer {
    id: initTimer
    interval: 400
    onTriggered: {
      // initialize
        gameArea.initializeField()
    }
  }

  Timer {
      id: initTimer2
      interval: 400
      onTriggered: {
          gameArea2.initializeField()
      }
  }

  Timer {
      id: initTimer3
      interval: 400
      onTriggered: {
          gameArea3.initializeField()
      }
  }

  // opens title window
  function openTitleWindow() {
    // show background
    filledGrid.opacity = 1
    scene.juicyMeterPercentage = 0
    gameTimer.stop()

    // show title window
    creditsWindow.hide()
    gameOverWindow.hide()
    demoMenuWindow.hide()
    titleWindow.show()
  }

  // when game ends, show game-over window and report score
  function currentGameEnded() {

    gameArea.gameEnded = true
    gameOverWindow.show()
    gameTimer.stop()
    scene.reportScore(scene.score)
  }

  function currentGame2Ended() {
      gameOverWindow.show()
      scene.reportScore(scene.score)
  }

  function currentGame3Ended() {
      gameOverWindow.show()
      scene.reportScore(scene.score)
  }

  // initialize game
  function startGame() {
    // hide windows

//    gameArea2.enabled =false
//    initTimer2.stop()
    titleWindow.hide()
    gameOverWindow.hide()
    creditsWindow.hide()
    demoMenuWindow.hide()

    // start loading animation
    whiteScreen.startLoading()
    scene.juicyMeterPercentage = 0
    gameArea.opacity=1
    // delay start of initialization
    initTimer.start()

  }

  // initialize game
  function startGame2() {
    // hide windows

//    gameArea.enabled=false
//    initTimer.stop()
    titleWindow.hide()
    gameOverWindow.hide()
    creditsWindow.hide()
    demoMenuWindow.hide()


    // start loading animation
    whiteScreen.startLoading()
    gameArea2.opacity=1
    // delay start of initialization
    initTimer2.start()
  }

  function startGame3() {
    // hide windows

//    gameArea.enabled=false
//    initTimer.stop()
    titleWindow.hide()
    gameOverWindow.hide()
    creditsWindow.hide()
    demoMenuWindow.hide()


    // start loading animation
    whiteScreen.startLoading()
    gameArea3.opacity=1
    // delay start of initialization
    initTimer3.start()
  }

  // 按下后退按钮
  function backPressed() {
//      initTimer.stop()
//      initTimer2.stop()
//      gameTimer.stop()

      creditsWindow.hide()
      gameOverWindow.hide()
      demoMenuWindow.hide()

      gameArea.opacity=0
      gameArea2.opacity=0
      gameArea3.opacity=0
      scene.juicyMeterPercentage = 0

      filledGrid.opacity =1
      juicyLogo.opacity=1
      titleWindow.opacity=1

//      titleWindow.show()
  }

  function startJuicy()
  {
      titleWindow.hide()
      gameOverWindow.hide()
      creditsWindow.hide()
      demoMenuWindow.show()
  }

  function backdemoMenu()
  {
      gameOverWindow.hide()
      demoMenuWindow.show()
  }

}
