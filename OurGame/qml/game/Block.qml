import Felgo 3.0
import QtQuick 2.0


EntityBase {
  id: block

  // allow entitymanager-pooling of entities，允许实体管理实体池
  entityType: "block"
  poolingEnabled: true

  // hide block if outside of game area,//如果在游戏区域之外，则隐藏块
  enabled: opacity == 1

  // each block knows its type and position on the field,每个块都知道它在场上的类型和位置
  property int type
  property int row
  property int column

  property int previousRow
  property int previousColumn

  // emit a signal when block should be swapped with another,当块应与另一个块交换时发出一个信号
  signal swapBlock(int row, int column, int targetRow, int targetColumn)//交换块
  signal swapFinished(int row, int column, int swapRow, int swapColumn) //交换完成
  signal fallDownFinished(var block) //跌倒完成

  // show different images for block types
  Image {
    anchors.fill: parent
    source: {
      if (type == 0)
        return "../../assets/img/fruits/Apple.png"
      else if(type == 1)
        return "../../assets/img/fruits/Banana.png"
      else if (type == 2)
        return "../../assets/img/fruits/Orange.png"
      else if (type == 3)
        return "../../assets/img/fruits/Pear.png"
      else if (type == 4)
        return "../../assets/img/fruits/BlueBerry.png"
      else if (type == 5)
        return "../../assets/img/fruits/WaterMelon.png"
      else if (type == 6)
        return "../../assets/img/fruits/Coconut.png"
      else
        return "../../assets/img/fruits/Lemon.png"
    }
  }

   //处理鼠标事件以在拖动时初始化块的交换
  MouseArea {
    id: mouse
    anchors.fill: parent

    // properties to handle dragging
    property bool dragging
    property bool waitForRelease
    property var dragStart

    // start drag on press
    onPressed: {
      if(!dragging && !waitForRelease) {
        dragging = true
        dragStart = { x: mouse.x, y: mouse.y }
      }
    }
    // stop drag on release
    onReleased: {
      dragging = false
      waitForRelease = false
    }

    //在玩家滑动一定距离后触发块的交换
    onPositionChanged: {
      if(!dragging || waitForRelease)
        return

      var xDistance = mouse.x - dragStart.x
      var yDistance = mouse.y - dragStart.y
    //Math.abs返回数的绝对值，
      //block.width=block.height=blockSize
      if((Math.abs(xDistance) < block.width/2)
          && (Math.abs(yDistance) < block.height/2))
        return

      var targetRow = block.row
      var targetCol = block.column

      if(Math.abs(xDistance) > Math.abs(yDistance)) {
        if(xDistance > 0)
          targetCol++ //列
        else
          targetCol--
      }
      else {
        if(yDistance > 0)
          targetRow++ //行
        else
          targetRow--
      }

      // signal block move
      dragging = false
      waitForRelease = true
      //触发swapBlock信号
      block.swapBlock(row, column, targetRow, targetCol)
    }
  }

  // rectangle for highlight effect，高亮效果
  Rectangle {
    id: highlightRect
    color: "white"
    anchors.fill: parent
    anchors.centerIn: parent
    opacity: 0
    z: 1
  }

  // particle effect，粒子效应
  Item {
    id: particleItem
    width: parent.width
    height: parent.height
    x: parent.width/2
    y: parent.height/2

    //粒子元素总是由粒子系统在内部管理，不能在QML中创建。 然而，有时它们通过信号暴露，以允许任意改变粒子状态
    Particle {
      id: sparkleParticle
      fileName: "../particles/FruitySparkle.json"
    }
    opacity: 0
    visible: opacity > 0
    enabled: opacity > 0
  }

  // fade out block before removal，在移除之前淡出块
  NumberAnimation {
    id: fadeOutAnimation
    target: block
    property: "opacity"
    duration: 500
    from: 1.0
    to: 0

    // 淡出完成后删除块
    onStopped: {
      sparkleParticle.stop()
      entityManager.removeEntityById(block.entityId)
    }
  }

  // 在移除之前淡出块
  NumberAnimation {
    id: fadeInAnimation
    target: block
    property: "opacity"
    duration: 1000
    from: 0
    to: 1
  }

  // 动画让块掉下来
  NumberAnimation {
    id: fallDownAnimation
    target: block
    property: "y"
    onStopped: {
      fallDownFinished(block)
    }
  }

  // 计时器等待跌倒，直到其他块淡出
  Timer {
    id: fallDownTimer
    interval: fadeOutAnimation.duration //设置触发器之间的间隔，以毫秒为单位。默认时间间隔为1000毫秒。
    repeat: false //如果repeat为true，则以指定的间隔重复触发定时器; 否则，计时器将以指定的间隔触发一次然后停止（即运行将设置为假）。重复默认为false。
    running: false  //如果设置为true，则启动计时器; 否则停止计时器。 对于非重复计时器，在触发计时器后，运行设置为false。运行默认值为false。

    onTriggered: {
      fallDownAnimation.start()
    }
  }

  // 在信号交换完成之前等待一下的定时器
  Timer {
    id: signalSwapFinished
    interval: 50
    onTriggered: swapFinished(block.previousRow, block.previousColumn, block.row, block.column)
  }

  // 滑动后移动块的动画
  NumberAnimation {
    id: swapAnimation
    target: block
    duration: 150
    onStopped: {
      signalSwapFinished.start() // trigger swapFinished
    }
  }

  // 用于突出显示块的动画，SequentialAnimation和ParallelAnimation类型允许多个动画一起运行。 SequentialAnimation中定义的动画是一个接一个地运行，而ParallelAnimation中定义的动画是同时运行的。
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

  // 开始淡出/删除块
  function remove() {
    particleItem.opacity = 1
    sparkleParticle.start()
    fadeOutAnimation.start()
  }

  // 触发掉下来
  function fallDown(distance) {
    // 在开始新的之前完成前一个掉落
    fallDownAnimation.complete()

      //每块移动100毫秒
      //例如 向下移动2个块需要200毫秒
    fallDownAnimation.duration = 100 * distance
    fallDownAnimation.to = block.y + distance * block.height

    //等待删除其他块然后再掉下来
    fallDownTimer.start()
  }

  // //向左/右/向上或向下移动块一步的功能
  function swap(targetRow, targetCol) {
    swapAnimation.complete()

    block.previousRow = block.row
    block.previousColumn = block.column

    if(targetRow !== block.row) {
      swapAnimation.property = "y"
      swapAnimation.to = block.y +
          (targetRow > block.row ? block.height : -block.height)
      block.row = targetRow
    }
    else if(targetCol !== block.column) {
      swapAnimation.property = "x"
      swapAnimation.to = block.x +
          (targetCol > block.column ? block.width : -block.width)
      block.column = targetCol
    }
    else
      return

    swapAnimation.start()
  }

  //突出显示该块以帮助玩家找到群组
  function highlight(active) {
    if(active) {
      highlightRect.opacity = 0
      highlightAnimation.start()
    }
    else {
      highlightAnimation.stop()
      highlightRect.opacity = 0
    }
  }

  // 淡入
  function fadeIn() {
    fadeInAnimation.start()
  }
}
