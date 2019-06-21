import Felgo 3.0
import QtQuick 2.0

Item {
  id: gameArea2

  width: blockSize * 8
  height: blockSize * 12

  property double blockSize
  property int rows: Math.floor(height / blockSize)
  property int columns: Math.floor(width / blockSize)

  property int maxTypes
  property int clicks

  // array for handling game field,它将游戏字段（网格）表示为块实体数组。
  property var field: []

  // 隐藏和禁用不透明度
  visible: gameArea2.opacity > 0
  enabled: gameArea2.opacity == 1


//  property bool fieldLocked

  signal initFinished2()
  // game over signal,传递游戏结束的信息。
  signal gameOver()


//  onFieldLockedChanged: {
//        gameOver()
//  }
  // calculate field index,返回特定网格位置的数组索引。我们可以使用此函数方便地访问字段数组中给定网格位置（行和列）的块。
  function index(row, column) {
    return row * columns + column
  }

  // fill game field with blocks,清空网格并用新块填充它。
  function initializeField() {
    // clear field
    gameArea2.clicks=0
    gameArea2.maxTypes=3
    clearField()

    // fill field
    for(var i = 0; i < rows; i++) {
      for(var j = 0; j < columns; j++) {
        gameArea2.field[index(i, j)] = createBlock(i, j)
      }
    }

    // 信号初始化完成
    initFinished2()
  }

  // clear game field,正确删除游戏区域中的所有块实体并清除字段数组。
  function clearField() {
    // remove entities
    for(var i = 0; i < gameArea2.field.length; i++) {
      var block = gameArea2.field[i]
      if(block !== null)  {
        entityManager2.removeEntityById(block.entityId)
      }
    }
    gameArea2.field = []
  }

  // create a new block at specific position,在特定网格位置向游戏添加新的随机块。
  function createBlock(row, column) {
    // configure block
    var entityProperties = {
      width: blockSize,
      height: blockSize,
      x: column * blockSize,
      y: row * blockSize,

      type: Math.floor(Math.random() * gameArea2.maxTypes), // random type
      row: row,
      column: column
    }

    // add block to game area
    var id = entityManager2.createEntityFromUrlWithProperties(
          Qt.resolvedUrl("Block2.qml"), entityProperties)

    // link click signal from block to handler function
    var entity = entityManager2.getEntityById(id)
    entity.clicked.connect(handleClick)

    return entity
  }

  // handle user clicks,将处理我们创建的块中的所有点击信号。参数告诉我们已单击的块的位置和类型。我们通过entity.clicked.connect（handleClick）命令将动态创建的块的信号与此函数连接起来。
  //row,column指定搜索的起始点。type设置搜索所需的块类型。
  function handleClick(row, column, type) {
      if(!isFieldReadyForNewBlockRemoval())
          return
      var fieldCopy = field.slice() //使用JavaScript函数slice（），这是复制整个数组的最快方法之一.必须是当前游戏领域的副本。该函数将更改给定字段以标记已计数的块。每当在邻域中找到所需类型的块时，它将从场中移除以避免再次检查它。
      var blockCount = getNumberOfConnectedBlocks(fieldCopy,row,column,type)
      if(blockCount>=3) {
          removeConnectedBlocks(fieldCopy)
          moveBlocksToButtom()

          var score = blockCount * (blockCount + 1) / 2
          scene.score += score

          if(isGameOver())
              gameOver()

          gameArea2.clicks++
          if((gameArea2.maxTypes<8)&&(gameArea2.clicks%10==0))
              gameArea2.maxTypes++
      }
  }

  function isFieldReadyForNewBlockRemoval() {
      for(var col=0;col<columns;col++) {
          var block = field[index(0,col)]
          if(block===null ||block.y<0)
              return false
      }
      return true
  }


  //如果出现以下情况，每次调用getNumberOfConnectedBlocks都将返回零：行或列参数超出了我们游戏领域的范围。给定位置没有阻挡。当计数块并从字段副本中删除时会发生这种情况。给定位置的块与所需类型不匹配。
  function getNumberOfConnectedBlocks(fieldCopy,row,column,type) {
      if(row >= rows || column>=columns ||row<0 ||column <0)
          return 0
      var block = fieldCopy[index(row,column)]

      if(block === null)
          return 0

      if(block.type !== type)
          return 0

      var count = 1

      //如果不是这种情况，则找到有效的块。然后，该函数从字段副本中删除此块。之后，通过再次调用getNumberOfConnectedBlocks以相同的方式检查所有相邻块，并且累加并返回邻域中所有连接块的数量。
      fieldCopy[index(row,column)] = null

      count += getNumberOfConnectedBlocks(fieldCopy, row + 1, column, type) // add number of blocks to the right
         count += getNumberOfConnectedBlocks(fieldCopy, row, column + 1, type) // add number of blocks below
         count += getNumberOfConnectedBlocks(fieldCopy, row - 1, column, type) // add number of blocks to the left
         count += getNumberOfConnectedBlocks(fieldCopy, row, column - 1, type) // add number of bocks above

      return count
  }

  // remove previously marked blocks
  function removeConnectedBlocks(fieldCopy) {
    // search for blocks to remove
    for(var i = 0; i < fieldCopy.length; i++) {
      if(fieldCopy[i] === null) {
        // remove block from field
        var block = gameArea2.field[i]
        if(block !== null) {
          gameArea2.field[i] = null
//          entityManager.removeEntityById(block.entityId)
            block.remove()
        }
      }
    }
  }

  //我们将从底部到顶部填充游戏区域的每一列，从左侧的列开始。每当我们在列中遇到空白点时，我们会搜索上面的下一个块并将其向下移动。
  function moveBlocksToButtom () {
      for(var col=0;col<columns;col++) {
          for(var row=rows-1;row>=0;row--) {
              if(gameArea2.field[index(row,col)]===null) {
                  var moveBlock = null
                  for (var moveRow = row-1;moveRow>=0;moveRow--) {
                      moveBlock = gameArea2.field[index(moveRow,col)]

                      if(moveBlock !== null) {
                          gameArea2.field[index(moveRow,col)] = null
                          gameArea2.field[index(row, col)] = moveBlock
                          moveBlock.row = row
                          moveBlock.y = row * gameArea2.blockSize
                          break
                      }
                  }
//                  if(moveBlock === null) {
//                      for(var newRow = row; newRow >= 0; newRow--) {
//                           var newBlock = createBlock(newRow, col)
//                           gameArea.field[index(newRow, col)] = newBlock
//                           newBlock.row = newRow
//                           newBlock.y = newRow * gameArea.blockSize
//                       }
//                       break
//                  }

                  if(moveBlock===null) {
                    var distance = row+1

                      for(var newRow=row;newRow>=0;newRow--) {
                          var newBlock = createBlock(newRow-distance,col)
                          gameArea2.field[index(newRow,col)]=newBlock //创建新块时，我们现在通过将newRow-distance设置为createBlock-call处的初始网格位置，将它们放置在游戏区域之外。
                          newBlock.row=newRow
                          newBlock.fallDown(distance) //将块移动到底部或创建新块时，我们只需使用fallDown函数而不是更改块的y位置
                      }

                      break
                  }
              }
          }
      }
  }

  function isGameOver() {
      var gameOver = true
      var fieldCopy = field.slice()

      // search for connected blocks in field
      for(var row = 0; row < rows; row++) {
            for(var col = 0; col < columns; col++) {

              // test all blocks
                var block = fieldCopy[index(row, col)]
                if(block !== null) {
                    var blockCount = getNumberOfConnectedBlocks(fieldCopy, row, col, block.type)

                    if(blockCount >= 3) {
                        gameOver = false
                        break
                    }
                }
            }
        }

        return gameOver
  }
}
