import QtQuick 2.0
import Felgo 3.0

Item {
    id:gameArea

    clip: true  //在游戏区域外剪辑水果

    // 应该是blockSize的倍数
    width: blockSize * columns
    height: blockSize * rows

    // 隐藏和禁用不透明度
    visible: gameArea.opacity > 0
    enabled: gameArea.opacity == 1


    //游戏区域是8列12行大
      property int rows: 12
      property int columns: 8

    property double blockSize   //游戏区域配置的属性
    property int maxTypes   // 增加游戏难度的属性
    property int clicks     //保存总的点击次数
    property var field: []      // 用于处理游戏领域的数组
    property bool gameEnded: false      //保存游戏是否结束
    property var helperBlocks: []   // 突出显示帮助玩家的块

    // 动画或交换块时锁定字段
    property bool fieldLocked
    property bool playerMoveInProgress

    // 连击
    property double comboFactor
    property int comboScore
    property bool overload

    signal gameOver()   //游戏结束信号
    signal initFinished1()   // 完成初始化

    onFieldLockedChanged: {
        if(!fieldLocked && !gameEnded){//field没有被锁，并且游戏没有结束
            findHelperBlocks()
            if(helperBlocks.length === 0 || scene.remainingTime <= 0){//// 如果不能删除更多的块，则表示游戏结束
                gameEnded = true
                gameOver()
            }else{
                helperTimer.start()
            }
        }else{
            helperTimer.stop()
            hideHelperBlocks()
        }
    }

    //计时器帮助玩家找到块
      Timer {
        id: helperTimer
        interval: 4000
        onTriggered: {
          showHelperBlocks()
        }
      }

    // 在块下降后检查新的可能删除的计时器
    Timer {
      id: fallDownTimer
      onTriggered: {
        recursiveBlockRemoval()
      }
    }

    //在点击demo后在各个定时器里面调用各个GaneArea的此函数
    function initializeField(){
        //重置难度
        gameArea.clicks = 0
        gameArea.maxTypes = 4

        // 如果尚未创建，则创建字段
        if(field.length != rows * columns)
            createField()

        // 填充字段
        fillField()

        //初始化property
        fieldLocked = false
        playerMoveInProgress = false
        comboFactor = 1
        comboScore = 0
        overload = false
        gameEnded = false

        //开始帮助
        hideHelperBlocks()
        findHelperBlocks()
        helperTimer.start()

        // 发送初始化完成信号
        initFinished1()
    }

    //只是创建了field
    function createField(){
//        console.log("NO")
        for(var i = 0; i<rows; i++){
            for(var j = 0; j<columns; j++)
                gameArea.field[index(i, j)]=createBlock(i, j, 0)// 填充默认块
        }
    }

    // 用随机块填充游戏field
    function fillField() {
      for(var i = 0; i < rows; i++) {
        for(var j = 0; j < columns; j++) {
          var currType = null

          // 得到随机类型
          currType = Math.floor(utils.generateRandomValueBetween(0, gameArea.maxTypes))

          var bannedType1 = -1
          var bannedType2 = -1

         //避免创建立即形成水平线的块
          if(j >= 2) {
            bannedType1 = gameArea.field[index(i, j - 2)].type
          }
          //避免创建立即形成垂直线的块
          if(currType !== null && i >= 2) {
            bannedType2 = gameArea.field[index(i - 2, j)].type
          }

          while(currType === bannedType1 || currType === bannedType2) {
            currType = (currType + 1) % gameArea.maxTypes //在找到有效类型之前增加类型
          }

          gameArea.field[index(i, j)].type = currType
        }
      }
    }

    // 计算字段索引
    function index(row, column) {
      return row * columns + column
    }

    // 在某个特定位置创建一个新块
    function createBlock(row, column, type) {
//        console.log("NO")
      var properties = {
        width: blockSize,
        height: blockSize,
        x: column * blockSize,
        y: row * blockSize,

        // 设置 row and column
        row: row,
        column: column,

        // 初始化可见性
        opacity: 1,

        // 基于参数或随机设置类型
        type: (type !== null)
               ? type    // 从参数中输入
               : Math.floor(utils.generateRandomValueBetween(0, gameArea.maxTypes)) // 随机类型
        }

        //基于entityType创建块实体（或重用池化块）
        var blockId = entityManager1.createEntityFromEntityTypeAndVariationType({entityType: "block"})

        // 获取块和设置属性
        var block = entityManager1.getEntityById(blockId)
        for (var propertyName in properties) {
          block[propertyName] = properties[propertyName]
        }

            //链接从块到处理函数的点击信号
        block.swapBlock.disconnect(handleSwap) //首先删除可能已经连接的池块
        block.swapBlock.connect(handleSwap)

        return block
    }

    //处理块交换
    function handleSwap(row, column, targetRow, targetColumn){
        if(fieldLocked || gameEnded)
          return

        // 交换block
        if(targetRow >= 0 && targetRow < rows && targetColumn >= 0 && targetColumn < columns) {
          fieldLocked = true
          scene.gameSound.playMoveBlock()//播放声音
          swapBlocks(row, column, targetRow, targetColumn)
        }
        else {
          scene.gameSound.playMoveBlockBack()
        }
    }

    //在场上交换两个block的位置
    function swapBlocks(row, column, row2, column2) {
      var block = field[index(row, column)]
      var block2 = field[index(row2, column2)]

    //断开所有处理程序，在无效的交换的是时候必须断开连接
      block.swapFinished.disconnect(handleSwapFinished)
      block2.swapFinished.disconnect(handleSwapFinished)

      //交换后block2连接处理交换
      block2.swapFinished.connect(handleSwapFinished)

      block.swap(row2, column2)
      block2.swap(row, column)

      field[index(row, column)] = block2
      field[index(row2, column2)] = block
    }

    // swap完成 - >检查字段是否有可能的块删除
    function handleSwapFinished(row, column, swapRow, swapColumn) {
      if(!playerMoveInProgress) {
        playerMoveInProgress = true

        if(!startRemovalOfBlocks(row, column) && !startRemovalOfBlocks(swapRow, swapColumn)) {
          scene.gameSound.playMoveBlockBack()
          swapBlocks(row, column, swapRow, swapColumn)
        }
        else {
          //每10次点击增加难度，直到maxTypes == 5
          gameArea.clicks++
          if((gameArea.maxTypes < 8) && (gameArea.clicks % 10 == 0))
            gameArea.maxTypes++

          playerMoveInProgress = false
        }
      }
      else {
     //没有任何东西可以删除，并且块被换回
        playerMoveInProgress = false
        fieldLocked = false
      }
    }

    //开始在给定位置移除块
    function startRemovalOfBlocks(row, column){
        var type = field[index(row, column)].type

        var fieldCopy = field.slice()//复制当前字段，允许我们在不修改真实游戏字段的情况下更改数组
        var blockCount = findConnectedBlocks(fieldCopy, row, column, type)
        if(blockCount < 3) {
          fieldCopy = field.slice()//没有这个就无法消去单独的纵向交换
          blockCount = findVerticallyConnectedBlocks(fieldCopy, row, column, type)
        }
        if(blockCount >= 3) {
          removeConnectedBlocks(fieldCopy, blockCount, false)
          return true
        }
        else
          return false
    }

    function findConnectedBlocks(fieldCopy,row,col,type) {
        //向左搜索
        var nrLeft = 1
        while((col - nrLeft >= 0) && (fieldCopy[index(row, col - nrLeft)] !== null) && (fieldCopy[index(row, col - nrLeft)].type === type)) {
          fieldCopy[index(row, col - nrLeft)] = null
          nrLeft++
        }

        //向右搜索
        var nrRight = 1
        while((col + nrRight < columns) && (fieldCopy[index(row, col + nrRight)] !== null) && (fieldCopy[index(row, col + nrRight)].type === type)) {
          fieldCopy[index(row, col + nrRight)] = null
          nrRight++
        }

        //向上搜索
        var nrUp = 1
        while((row - nrUp >= 0) && (fieldCopy[index(row - nrUp, col)] !== null) && (fieldCopy[index(row - nrUp, col)].type === type)) {
          fieldCopy[index(row - nrUp, col)] = null
          nrUp++
        }

        //向下搜索
        var nrDown = 1
        while((row + nrDown < rows) && (fieldCopy[index(row + nrDown, col)] !== null) && (fieldCopy[index(row + nrDown, col)].type === type)) {
          fieldCopy[index(row + nrDown, col)] = null
          nrDown++
        }

        fieldCopy[index(row, col)] = null
        return nrLeft + nrRight - 1
    }

    //纵向相连的block
    function findVerticallyConnectedBlocks(fieldCopy, row, col, type) {
      var nrUp = 1
      //向上
      while((row - nrUp >= 0) && (fieldCopy[index(row - nrUp, col)] !== null) && (fieldCopy[index(row - nrUp, col)].type === type)) {
        fieldCopy[index(row - nrUp, col)] = null
        nrUp++
      }
      //向下
      var nrDown = 1
      while((row + nrDown < rows) && (fieldCopy[index(row + nrDown, col)] !== null) && (fieldCopy[index(row + nrDown, col)].type === type)) {
        fieldCopy[index(row + nrDown, col)] = null
        nrDown++
      }

      fieldCopy[index(row, col)] = null
      return nrUp + nrDown - 1
    }

    //获取row，col周围相同类型的水平块数
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
      // 播放声音
      if(overload)
          scene.gameSound.playOverloadClear()
      else
          scene.gameSound.playFruitClear()

      for(var groupNr = 0; groupNr < blockCounts.length; groupNr++) {

          var blockCount = blockCounts[groupNr]

          //计算并提高分数
          var score = blockCount * (blockCount + 1) / 2
          var totalScore = score * comboFactor
          // combos increase score
          gameArea.comboScore += totalScore
          scene.score +=  totalScore
          gameData.score = scene.score
          gameData.save()
      }
      if(clearAll) {
        fallDownTimer.interval = 1000
        fallDownTimer.start() //将触发recursiveBlockRemoval（）
      }
      else {
        //向下移动块并移除已连接的块，直到不再删除块为止
        moveBlocksToBottom()
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

    //将剩余的块移动到底部，并用新块填充列
    function moveBlocksToBottom() {
      var maxDistance = 0 //块的最长距离
      var longestFallBlock = null

    //检查空字段的所有列
      for(var col = 0; col < columns; col++) {

     //从字段的底部开始
        for(var row = rows - 1; row >= 0; row--) {

         //在网格中找到空白点
          if(gameArea.field[index(row, col)] === null) {

            //找到要向下移动的块
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

            //如果找不到块，请用新块填满整列
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

              //列已经填满，无需再次检查更高的行
              break
            }
          }

        }//从底部开始检查行
      }//结束检查空字段的列

      if(longestFallBlock != null) {
        longestFallBlock.fallDownFinished.connect(handleFallFinished)
      }
    }



    //触发在完成下落后要执行的事件
     function handleFallFinished(block) {
       block.fallDownFinished.disconnect(handleFallFinished)
       fallDownTimer.interval = 250
       fallDownTimer.start() // 将触发recursiveBlockRemoval（）
     }

   //递归删除所有block，直到不再删除块为止
     function recursiveBlockRemoval() {
       var blockCounts = []
       var nextGameField = field.slice()

         //在字段中搜索连接的块
         for(var row = rows-1; row >= 0; row--) {
              for(var col = 0; col < columns; col++) {
                  //测试所有块
                  //复制字段
                   var block = nextGameField[index(row, col)]
                   if(block !== null) {
                   //检查要删除的水平或垂直块
                       var fieldCopy = nextGameField.slice()
                       var blockCount = findHorizontallyConnectedBlocks(fieldCopy, row, col, block.type)
                       if(blockCount < 3) {
                               fieldCopy = nextGameField.slice()
                               blockCount = findVerticallyConnectedBlocks(fieldCopy, row, col, block.type)
                       }

           //记住要删除的当前组
                       if(blockCount >= 3) {
                               nextGameField = fieldCopy
                               blockCounts.push(blockCount)
                       }
                   }
              }
        }

       //如果不能删除更多block，则停止
       if(blockCounts.length === 0) {
        //增加果汁
         var newJuicyLevel = scene.juicyMeterPercentage + (gameArea.comboScore / 5) // 500分= 100％多汁的米

         if(overload) {
           newJuicyLevel = scene.juicyMeterPercentage + (gameArea.comboScore / 40) // 2000 pts =超载时100％多汁表
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

         //重置组合属性
         comboFactor = 1
         comboScore = 0

        //解锁字段（可能的新动作）
         fieldLocked = false

         return //如果没有找到块，则停止递归
       }
       else {
         comboFactor += 0.5

         //显示基于combofactor的叠加文本
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


       //也会在向下移动块后再次搜索（递归）
         removeConnectedBlocks(nextGameField, blockCounts, false)
       }
     }

     //找到可能的块行以向玩家显示帮助
       function findHelperBlocks() {
         //搜索字段以查找可能的移动
           for(var row = rows - 1; row >= 0; row --) {
             for (var col = 0; col < columns; col ++) {
                 var block = field[index(row, col)]
                 var type = block.type

             // 向下
                 if(row + 1 < rows) {
                     if(getLengthOfHorizontalBlock(row + 1, col, type, 0) >= 3
                   || getLengthOfVerticalBlock(row + 1, col, type, 1) >= 3) {
                         helperBlocks.push(block)
                         return
                     }
                 }
             // 向上
             if(row - 1 >= 0) {
               if(getLengthOfHorizontalBlock(row - 1, col, type, 0) >= 3
                   || getLengthOfVerticalBlock(row - 1, col, type, -1) >= 3) {
                 helperBlocks.push(block)
                 return
               }
             }
             //向右
             if(col + 1 < columns) {
               if(getLengthOfVerticalBlock(row, col + 1, type, 0) >= 3
                   || getLengthOfHorizontalBlock(row, col + 1, type, 1) >= 3)  {
                 helperBlocks.push(block)
                 return
               }
             }
             //向左
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
         // 向左
         while(directions < 1 && col - nr >= 0 && field[index(row, col - nr)].type === type) {
           helperBlocks.push(field[index(row, col - nr)])
           nr++
         }

         //向右
         nr = 1
         while(directions > -1 && col + nr < columns && field[index(row, col + nr)].type === type) {
           helperBlocks.push(field[index(row, col+nr)])
           nr++
         }

         return helperBlocks.length + 1 //length属性可设置或返回数组中元素的数目。
       }

       //获取row，col周围相同类型的垂直块数
       function getLengthOfVerticalBlock(row, col, type, directions) {
         helperBlocks = []
         var nr = 1
         // 向左
         while(directions < 1 && row - nr >= 0 && field[index(row - nr, col)].type === type) {
           helperBlocks.push(field[index(row - nr, col)])
           nr++
         }
         // 向右
         nr = 1
         while(directions > -1 && row + nr < rows && field[index(row + nr, col)].type === type) {
           helperBlocks.push(field[index(row + nr, col)])
           nr++
         }
         return helperBlocks.length + 1
       }

       //删除所有块并创建新块（当果汁满时触发）
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


       // 隐藏一行的辅助块
       function hideHelperBlocks() {
         for(var i = 0; i < helperBlocks.length; i++) {
           var block = helperBlocks[i]
           block.highlight(false)
         }
         helperBlocks = []
       }

       // 显示一行帮助玩家
       function showHelperBlocks() {
         // highlight blocks
         for(var i = 0; i < helperBlocks.length; i++) {
           var block = helperBlocks[i]
           block.highlight(true)
         }
       }
}
