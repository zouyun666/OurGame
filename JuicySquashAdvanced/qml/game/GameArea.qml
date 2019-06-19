import Felgo 3.0
import QtQuick 2.0

Item {
  id: gameArea

  // clip fuits outside of gameArea
  clip: true

  // properties for game area configuration
  property double blockSize

  // the game field is 8 columns by 12 rows big
  property int rows: 12
  property int columns: 8

  // 应该是blockSize的倍数
  width: blockSize * columns
  height: blockSize * rows

  // 隐藏和禁用不透明度
  visible: gameArea.opacity > 0
  enabled: gameArea.opacity == 1

  // 增加游戏难度的属性
  property int maxTypes
  property int clicks

  // 用于处理游戏领域的数组
  property var field: []

  // 动画或交换块时锁定字段
  property bool fieldLocked
  property bool playerMoveInProgress

  // 突出显示帮助玩家的块
  property var helperBlocks: []

  // 连击
  property double comboFactor
  property int comboScore
  property bool overload

  // game ended
  property bool gameEnded: false

  // gameover signal
  signal gameOver()

  // 完成初始化
  signal initFinished()

  // 在字段解锁后向助手显示一些计时器
  onFieldLockedChanged: {
    if(!fieldLocked && !gameEnded) {
      // field is ready for player to make a move, check if moves possible
      findHelperBlocks()
      if(helperBlocks.length === 0 || scene.remainingTime <= 0) {
        // 如果不能删除更多的块，则表示游戏结束
        gameEnded = true
        gameOver()
      }
      else {
        // 一段时间后显示帮手块
        helperTimer.start()
      }
    }
    else {
      helperTimer.stop()
      hideHelperBlocks()
    }
  }

  // 在块下降后检查新的可能删除的计时器
  Timer {
    id: fallDownTimer
    onTriggered: {
      recursiveBlockRemoval()
    }
  }

  // timer to help player to find blocks
  Timer {
    id: helperTimer
    interval: 4000
    onTriggered: {
      showHelperBlocks()
    }
  }

  // calculate field index
  function index(row, column) {
    return row * columns + column
  }

//用块填充游戏区域
  function initializeField() {
    // reset difficulty
    gameArea.clicks = 0
    gameArea.maxTypes = 4

    // create field if not yet created
    if(field.length != rows * columns)
      createField()

    // fill field
    fillField()

    // initialize properties
    fieldLocked = false
    playerMoveInProgress = false
    comboFactor = 1
    comboScore = 0
    overload = false
    gameEnded = false

    // start helper
    hideHelperBlocks()
    findHelperBlocks()
    helperTimer.start()

    // signal initialization finished
    initFinished()
  }

  // fill game field with blocks
  function createField() {
    for(var i = 0; i < rows; i++) {
      for(var j = 0; j < columns; j++) {
        gameArea.field[index(i, j)] = createBlock(i, j, 0) // 填充默认块
      }
    }
  }

  // fill game field with random blocks
  function fillField() {
    for(var i = 0; i < rows; i++) {
      for(var j = 0; j < columns; j++) {
        var currType = null

        // get randomType
        currType = Math.floor(utils.generateRandomValueBetween(0, gameArea.maxTypes))

        var bannedType1 = -1
        var bannedType2 = -1

        // avoid creating blocks that immediately form a horizontal line
        if(j >= 2) {
          bannedType1 = gameArea.field[index(i, j - 2)].type
        }
        // avoid creating block that immediately form a vertical line
        if(currType !== null && i >= 2) {
          bannedType2 = gameArea.field[index(i - 2, j)].type
        }

        while(currType === bannedType1 || currType === bannedType2) {
          currType = (currType + 1) % gameArea.maxTypes // increase type until a valid type is found
        }

        gameArea.field[index(i, j)].type = currType
      }
    }
  }

  // 用新字段替换当前字段
  function replaceFieldWithNewField() {
    // 创建并展示新领域
    for(var i = 0; i < gameArea.field.length; i++) {
      gameArea.field[i].opacity = 0
      gameArea.field[i].type = utils.generateRandomValueBetween(0, gameArea.maxTypes - 1) // 总是少填一种
      gameArea.field[i].fadeIn()
    }
  }

  //删除所有块并创建新块（当多汁仪表满时触发）
  function removeAllBlocks() {
    fieldLocked = true
    overload = true

    var counts = []
    for(var row = 0; row < rows; row++) {
      for(var col = 0; col < columns; col++) {
        counts.push(columns/2) //？push() 方法可向数组的末尾添加一个或多个元素，并返回新的长度。
      }
    }

    removeConnectedBlocks(null, counts, true)
  }

  // create a new block at specific position
  function createBlock(row, column, type) {
    // configure block
    var properties = {
      width: blockSize,
      height: blockSize,
      x: column * blockSize,
      y: row * blockSize,

      // set row and column
      row: row,
      column: column,

      // initially visible
      opacity: 1,

      // set type based at parameter or random
      type: (type !== null)
             ? type    // type from parameter
             : Math.floor(utils.generateRandomValueBetween(0, gameArea.maxTypes)) // random type
    }

    //基于entityType创建块实体（或重用池化块）
    var blockId = entityManager.createEntityFromEntityTypeAndVariationType({entityType: "block"})

    // get block and set properties
    var block = entityManager.getEntityById(blockId)
    for (var propertyName in properties) {
      block[propertyName] = properties[propertyName]
    }

//链接从块到处理函数的点击信号
    block.swapBlock.disconnect(handleSwap) //首先删除可能已经连接的池块
    block.swapBlock.connect(handleSwap)

    return block
  }

  // handle swaps of blocks
  function handleSwap(row, column, targetRow, targetColumn) {
    if(fieldLocked || gameEnded)
      return

    // swap blocks
    if(targetRow >= 0 && targetRow < rows && targetColumn >= 0 && targetColumn < columns) {
      fieldLocked = true
      scene.gameSound.playMoveBlock()
      swapBlocks(row, column, targetRow, targetColumn)
    }
    else {
      scene.gameSound.playMoveBlockBack()
    }
  }

  // swap was finished -> check field for possible block removals
  function handleSwapFinished(row, column, swapRow, swapColumn) {
    if(!playerMoveInProgress) {
      playerMoveInProgress = true

      if(!startRemovalOfBlocks(row, column) && !startRemovalOfBlocks(swapRow, swapColumn)) {
        // swap is not possible, no blocks can be removed
        scene.gameSound.playMoveBlockBack()
        swapBlocks(row, column, swapRow, swapColumn)
      }
      else {
        // increase difficulty every 10 clicks until maxTypes == 5
        gameArea.clicks++
        if((gameArea.maxTypes < 8) && (gameArea.clicks % 10 == 0))
          gameArea.maxTypes++

        playerMoveInProgress = false
      }
    }
    else {
      // nothing could be removed and blocks got swapped back
      playerMoveInProgress = false
      fieldLocked = false
    }
  }

  // starts removal of blocks at given position
  function startRemovalOfBlocks(row, column) {
    var type = field[index(row, column)].type

    // copy current field, allows us to change the array without modifying the real game field
    // this simplifies the algorithms to search for connected blocks and their removal
    var fieldCopy = field.slice()

    // count and delete horizontally OR vertically connected blocks
    var blockCount = findHorizontallyConnectedBlocks(fieldCopy, row, column, type)
    if(blockCount < 3) {
      fieldCopy = field.slice()
      blockCount = findVerticallyConnectedBlocks(fieldCopy, row, column, type)
    }

    if(blockCount >= 3) {
      removeConnectedBlocks(fieldCopy, [blockCount], false)
      return true
    }
    else
      return false
  }

  // get number of horizontal blocks of same type around row, col
  function findHorizontallyConnectedBlocks(fieldCopy, row, col, type) {
    var nrLeft = 1
    // look left
    while((col - nrLeft >= 0) && (fieldCopy[index(row, col - nrLeft)] !== null) && (fieldCopy[index(row, col - nrLeft)].type === type)) {
      fieldCopy[index(row, col - nrLeft)] = null
      nrLeft++
    }
    // look right
    var nrRight = 1
    while((col + nrRight < columns) && (fieldCopy[index(row, col + nrRight)] !== null) && (fieldCopy[index(row, col + nrRight)].type === type)) {
      fieldCopy[index(row, col + nrRight)] = null
      nrRight++
    }

    fieldCopy[index(row, col)] = null
    return nrLeft + nrRight - 1
  }

  // get number of vertical blocks of same type around row, col
  function findVerticallyConnectedBlocks(fieldCopy, row, col, type) {
    var nrUp = 1
    // look up
    while((row - nrUp >= 0) && (fieldCopy[index(row - nrUp, col)] !== null) && (fieldCopy[index(row - nrUp, col)].type === type)) {
      fieldCopy[index(row - nrUp, col)] = null
      nrUp++
    }
    // look down
    var nrDown = 1
    while((row + nrDown < rows) && (fieldCopy[index(row + nrDown, col)] !== null) && (fieldCopy[index(row + nrDown, col)].type === type)) {
      fieldCopy[index(row + nrDown, col)] = null
      nrDown++
    }

    fieldCopy[index(row, col)] = null
    return nrUp + nrDown - 1
  }

  // 删除以前标记的块
  function removeConnectedBlocks(fieldCopy, blockCounts, clearAll) {
    if(clearAll) {
      replaceFieldWithNewField()
    }
    else {
      // 搜索要删除的块
      for(var i = 0; i < fieldCopy.length; i++) {
        if(fieldCopy[i] === null) {
          // 从字段中删除块
          var block = gameArea.field[i]
          if(block !== null) {
            gameArea.field[i] = null
            block.remove()
          }
        }
      }
    }

    // play sound
    if(overload)
      scene.gameSound.playOverloadClear()
    else
      scene.gameSound.playFruitClear()

    // add score for all groups that will be removed
    for(var groupNr = 0; groupNr < blockCounts.length; groupNr++) {
      var blockCount = blockCounts[groupNr]

      // calculate and increase score
      // this will increase the added score for each block, e.g. four blocks will be 1+2+3+4 = 10 points
      var score = blockCount * (blockCount + 1) / 2
      var totalScore = score * comboFactor // combos increase score
      gameArea.comboScore += totalScore
      scene.score +=  totalScore
    }

    if(clearAll) {
      fallDownTimer.interval = 1000
      fallDownTimer.start() // will trigger recursiveBlockRemoval()
    }
    else {
      // move blocks down and remove connected blocks until no more blocks can be removed
      moveBlocksToBottom()
    }
  }

  // move remaining blocks to the bottom and fill up columns with new blocks
  function moveBlocksToBottom() {
    var maxDistance = 0 // longest fall down distance of a block
    var longestFallBlock = null

    // check all columns for empty fields
    for(var col = 0; col < columns; col++) {

      // start at the bottom of the field
      for(var row = rows - 1; row >= 0; row--) {

        // find empty spot in grid
        if(gameArea.field[index(row, col)] === null) {

          // find block to move down
          var moveBlock = null
          for(var moveRow = row - 1; moveRow >= 0; moveRow--) {
            moveBlock = gameArea.field[index(moveRow,col)]

            if(moveBlock !== null) {
              gameArea.field[index(moveRow,col)] = null
              gameArea.field[index(row, col)] = moveBlock
              moveBlock.row = row
              moveBlock.fallDown(row - moveRow)
              break
            }
          }

          // if no block found, fill whole column up with new blocks
          if(moveBlock === null) {
            var distance = row + 1

            for(var newRow = row; newRow >= 0; newRow--) {
              var newBlock = createBlock(newRow - distance, col, null) // random block
              gameArea.field[index(newRow, col)] = newBlock
              newBlock.row = newRow
              newBlock.fallDown(distance)

              if(distance > maxDistance) {
                maxDistance = distance
                longestFallBlock = newBlock
              }
            }

            // column already filled up, no need to check higher rows again
            break
          }
        }

      } // end check rows starting from the bottom
    } // end check columns for empty fields

    if(longestFallBlock != null) {
      longestFallBlock.fallDownFinished.connect(handleFallFinished)
    }
  }

  // triggers events to do after fall-down is finished
  function handleFallFinished(block) {
    block.fallDownFinished.disconnect(handleFallFinished)
    fallDownTimer.interval = 250
    fallDownTimer.start() // will trigger recursiveBlockRemoval()
  }

  // recursively remove all blocks until no more blocks can be removed
  function recursiveBlockRemoval() {
    var blockCounts = []
    var nextGameField = field.slice()

    // search for connected blocks in field
    for(var row = rows-1; row >= 0; row--) {
      for(var col = 0; col < columns; col++) {
        // test all blocks
        // copy field
        var block = nextGameField[index(row, col)]
        if(block !== null) {
          // check for horizontal or vertical blocks to remove
          var fieldCopy = nextGameField.slice()
          var blockCount = findHorizontallyConnectedBlocks(fieldCopy, row, col, block.type)
          if(blockCount < 3) {
            fieldCopy = nextGameField.slice()
            blockCount = findVerticallyConnectedBlocks(fieldCopy, row, col, block.type)
          }

          // memorize current group to be removed
          if(blockCount >= 3) {
            nextGameField = fieldCopy
            blockCounts.push(blockCount)
          }
        }
      }
    }

    // stop if no more blocks can be removed
    if(blockCounts.length === 0) {
      // increase juicy meter
      var newJuicyLevel = scene.juicyMeterPercentage + (gameArea.comboScore / 5) // 500 pts = 100% juicy meter

      if(overload) {
        newJuicyLevel = scene.juicyMeterPercentage + (gameArea.comboScore / 40) // 2000 pts = 100% juicy meter when overload
        overload = false

        if(Math.round(utils.generateRandomValueBetween(0,1)) == 0)
          scene.overlayText.showSmooth()
        else
          scene.overlayText.showDelicious()
      }

      if(newJuicyLevel > 100)
        newJuicyLevel = 100

      scene.juicyMeterPercentage = newJuicyLevel
      scene.gameSound.playUpgrade()

      // reset combo properties
      comboFactor = 1
      comboScore = 0

      // unlock field (new move possible)
      fieldLocked = false

      return // stop recursion if no blocks found
    }
    else {
      comboFactor += 0.5

      // show overlay texts based on combofactor
      if(!overload) {
        if(comboFactor == 1.5) { // combo of 2
          if(Math.round(utils.generateRandomValueBetween(0,1)) == 0)
            scene.overlayText.showFruity()
          else
            scene.overlayText.showSweet()
        }
        else if(comboFactor == 2.5) { // combo of 4
          scene.overlayText.showYummy()
        }
        else if(comboFactor == 3) { // combo of 5
          scene.overlayText.showRefreshing()
        }
      }


      // will also search again after moving blocks down (recursion)
      removeConnectedBlocks(nextGameField, blockCounts, false)
    }
  }

  // swaps positions of two blocks on field
  function swapBlocks(row, column, row2, column2) {
    var block = field[index(row, column)]
    var block2 = field[index(row2, column2)]

    // disconnect all handlers
    block.swapFinished.disconnect(handleSwapFinished)
    block2.swapFinished.disconnect(handleSwapFinished)

//在第二次交换动画完成后做出反应
    block2.swapFinished.connect(handleSwapFinished)

    block.swap(row2, column2)
    block2.swap(row, column)

    field[index(row, column)] = block2
    field[index(row2, column2)] = block
  }

//找到可能的块行以向玩家显示帮助
  function findHelperBlocks() {
    //搜索字段以查找可能的移动
      for(var row = rows - 1; row >= 0; row --) {
        for (var col = 0; col < columns; col ++) {
            var block = field[index(row, col)]
            var type = block.type

        // move down?
            if(row + 1 < rows) {
                if(getLengthOfHorizontalBlock(row + 1, col, type, 0) >= 3
              || getLengthOfVerticalBlock(row + 1, col, type, 1) >= 3) {
                    helperBlocks.push(block)
                    return
                }
            }
        // move up?
        if(row - 1 >= 0) {
          if(getLengthOfHorizontalBlock(row - 1, col, type, 0) >= 3
              || getLengthOfVerticalBlock(row - 1, col, type, -1) >= 3) {
            helperBlocks.push(block)
            return
          }
        }
        // move right?
        if(col + 1 < columns) {
          if(getLengthOfVerticalBlock(row, col + 1, type, 0) >= 3
              || getLengthOfHorizontalBlock(row, col + 1, type, 1) >= 3)  {
            helperBlocks.push(block)
            return
          }
        }
        // move left?
        if(col - 1 >= 0) {
          if(getLengthOfVerticalBlock(row, col - 1, type, 0) >= 3
              || getLengthOfHorizontalBlock(row, col - 1, type, -1) >= 3)  {
            helperBlocks.push(block)
            return
          }
        }
      }
    }
  }

  //获取row，col周围相同类型的水平块数
  function getLengthOfHorizontalBlock(row, col, type, directions) {
    helperBlocks = []
    var nr = 1
    // look left
    while(directions < 1 && col - nr >= 0 && field[index(row, col - nr)].type === type) {
      helperBlocks.push(field[index(row, col - nr)])
      nr++
    }

    // look right
    nr = 1
    while(directions > -1 && col + nr < columns && field[index(row, col + nr)].type === type) {
      helperBlocks.push(field[index(row, col+nr)])
      nr++
    }

    return helperBlocks.length + 1
  }

  // get number of vertical blocks of same type around row, col
  function getLengthOfVerticalBlock(row, col, type, directions) {
    helperBlocks = []
    var nr = 1
    // look left
    while(directions < 1 && row - nr >= 0 && field[index(row - nr, col)].type === type) {
      helperBlocks.push(field[index(row - nr, col)])
      nr++
    }
    // look right
    nr = 1
    while(directions > -1 && row + nr < rows && field[index(row + nr, col)].type === type) {
      helperBlocks.push(field[index(row + nr, col)])
      nr++
    }
    return helperBlocks.length + 1
  }

  // shows blocks of a line to help player
  function showHelperBlocks() {
    // highlight blocks
    for(var i = 0; i < helperBlocks.length; i++) {
      var block = helperBlocks[i]
      block.highlight(true)
    }
  }

  // hides helper blocks of a line
  function hideHelperBlocks() {
    for(var i = 0; i < helperBlocks.length; i++) {
      var block = helperBlocks[i]
      block.highlight(false)
    }
    helperBlocks = []
  }
}

