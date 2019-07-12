import QtQuick 2.0

Item {

    id: gameArea3

    width: blockSize * 8
    height: blockSize * 12
    visible: gameArea3.opacity > 0
    enabled: gameArea3.opacity == 1
    property double blockSize
    property int rows: Math.floor(height/blockSize)
    property int columns: Math.floor(width/blockSize)
    property var field:[]
    property int maxTypes

    property var point: []
    property int linkIndex: 0
    property var link: [99, 99]
    property int linelevel: 0
    property var lucky: []

    signal initFinished3()
    signal gameOver()

    signal chance



    Rectangle {
        id: rectangle
        color: "yellow"
        opacity: 0
    }
    Rectangle {
        id: rectangle2
        color: "yellow"
        opacity: 0
    }
    Rectangle {
        id: rectangle3
        color: "yellow"
        opacity: 0
    }

    Timer {
        id: timer
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            rectangle.opacity = 0
            rectangle2.opacity = 0
            rectangle3.opacity = 0
        }
    }

    function index(row, column){
        return row * columns + column
    }

    function initializeField(){

        gameArea3.maxTypes=8

        gameArea3.lucky = [Math.floor(Math.random(
                                         ) * gameArea3.rows * gameArea3.columns), Math.floor(Math.random() * gameArea3.rows * gameArea3.columns), Math.floor(Math.random() * gameArea3.rows * gameArea3.columns)]

        clearField()

        for(var i=0; i<rows; i++){
            for(var j=0; j<columns; j++){
                gameArea3.field[index(i, j)] = createBlock(i, j)
            }
        }

        initFinished3()
    }

    function clearField(){
        for(var i=0; i<gameArea3.field.length;i++){
            var block = gameArea3.field[i]
            if(block !== null){
                entityManager3.removeEntityById(block.entityId)
            }
        }
        gameArea3.field = []
    }

    function islucky(row, column) {
        for (var i = 0; i !== 3; i++) {
            if (lucky[i] === index(row, column))
                return 1
        }
        return 0
    }

    function createBlock(row, column){
        var entityProperties = {
            width: blockSize,
            height: blockSize,
            x: column * blockSize,
            y: row * blockSize,
            type: Math.floor(Math.random()*gameArea3.maxTypes),//只有5种水果
            row: row,
            column: column,
            selected: 0 ,
            chances: islucky(row, column)
        }
        var id = entityManager3.createEntityFromUrlWithProperties(Qt.resolvedUrl("../entities/Block3.qml"), entityProperties)

        var entity = entityManager3.getEntityById(id)
        entity.clicked.connect(handleClick)

        return entity
    }

    function handleClick(row, column, type)
    {
        var fieldCopy = gameArea3.field.slice()
        link[linkIndex] = index(row, column)
        if(linkIndex === 0)
        {
            if (link[1] !== 99)
            {
                if(fieldCopy[link[1]].type === type && (fieldCopy[link[1]].column !== column) && checkNoBarrier(fieldCopy[link[1]].row, fieldCopy[link[1]].column, row,column))
                {
                    if (linelevel !== 0)
                    {
                        timer.restart()
                        if (linelevel === 1)
                        {
                            drawline1(point[0], point[1], point[2], point[3])
                            rectangle2.opacity = 0
                            rectangle3.opacity = 0
                        }else if(linelevel === 2)
                        {
                            drawline1(point[0], point[1], point[2], point[3])
                            drawline2(point[4], point[5], point[2], point[3])
                            rectangle3.opacity = 0
                        }else
                        {
                            drawline1(point[0], point[1], point[2], point[3])
                            drawline2(point[4], point[5], point[2], point[3])
                            drawline3(point[4], point[5], point[6], point[7])
                        }

                        scene.score+=5;
                        gameData.score = scene.score
                        gameData.save()

                        if(fieldCopy[link[0]].chances === 1 || fieldCopy[link[1]].chances === 1)
                            chance()
                         var block = gameArea3.field[link[0]]
                        gameArea3.field[link[0]] = null

//                        block.remove()
                        entityManager3.removeEntityById(block.entityId)
                        link[0] = 99

                        block = gameArea3.field[link[1]]
                        gameArea3.field[link[1]] = null

//                        block.remove()
                        entityManager3.removeEntityById(block.entityId)
                        link[1] = 99
                    }else
                        linkIndex = 1
                }else
                    linkIndex = 1
            }else
                linkIndex = 1
         }else{
                if (link[0] !== 99){
                    if(fieldCopy[link[0]].type === type && (fieldCopy[link[0]].row !== row || fieldCopy[link[0]].column !== column) && checkNoBarrier(fieldCopy[link[0]].row, fieldCopy[link[0]].column, row, column)){
                        if (linelevel !== 0){
                            timer.restart()
                            if (linelevel === 1){
                                drawline1(point[0], point[1], point[2], point[3])
                                rectangle2.opacity = 0
                                rectangle3.opacity = 0
                            }else if(linelevel === 2){
                                drawline1(point[0], point[1], point[2], point[3])
                                drawline2(point[4], point[5], point[2], point[3])
                                rectangle3.opacity = 0
                            }else{
                                drawline1(point[0], point[1], point[2], point[3])
                                drawline2(point[4], point[5], point[2], point[3])
                                drawline3(point[4], point[5], point[6], point[7])
                            }

                            scene.score += 9;
                            gameData.score = scene.score
                            gameData.save()

                            if(fieldCopy[link[0]].chances === 1 || fieldCopy[link[1]].chances === 1)
                                chance()
                            block = gameArea3.field[link[0]]
                            gameArea3.field[link[0]] = null

//                            block.remove()
                            entityManager3.removeEntityById(block.entityId)
                            link[0] = 99

                            block = gameArea3.field[link[1]]
                            gameArea3.field[link[1]] = null

                            //block.remove()
                            entityManager3.removeEntityById(block.entityId)
                            link[1] = 99
                        }else
                            linkIndex = 0
                    }else
                        linkIndex = 0
                }else
                    linkIndex = 0
            }
    }

    function drawline1(row1, col1, row2, col2) {
        if ((row1 === row2) || (col1 === col2)) {
            if ((row1 === row2) && (col1 !== col2)) {
                if (col1 < col2) {
                    rectangle.width = (col2 - col1) * blockSize
                    rectangle.height = 1
                    rectangle.opacity = 1
                    rectangle.x = col1 * blockSize + blockSize / 2
                    rectangle.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle.width = (col1 - col2) * blockSize
                    rectangle.height = 1
                    rectangle.opacity = 1
                    rectangle.x = col2 * blockSize + blockSize / 2
                    rectangle.y = row2 * blockSize + blockSize / 2
                }
            }
            if ((row1 !== row2) && (col1 === col2)) {
                if (row1 < row2) {
                    rectangle.width = 1
                    rectangle.height = (row2 - row1) * blockSize
                    rectangle.opacity = 1
                    rectangle.x = col1 * blockSize + blockSize / 2
                    rectangle.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle.width = 1
                    rectangle.height = (row1 - row2) * blockSize
                    rectangle.opacity = 1
                    rectangle.x = col2 * blockSize + blockSize / 2
                    rectangle.y = row2 * blockSize + blockSize / 2
                }
            }
        }
    }
    function drawline2(row1, col1, row2, col2) {
        if ((row1 === row2) || (col1 === col2)) {
            if ((row1 === row2) && (col1 !== col2)) {
                if (col1 < col2) {
                    rectangle2.width = (col2 - col1) * blockSize
                    rectangle2.height = 1
                    rectangle2.opacity = 1
                    rectangle2.x = col1 * blockSize + blockSize / 2
                    rectangle2.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle2.width = (col1 - col2) * blockSize
                    rectangle2.height = 1
                    rectangle2.opacity = 1
                    rectangle2.x = col2 * blockSize + blockSize / 2
                    rectangle2.y = row2 * blockSize + blockSize / 2
                }
            }
            if ((row1 !== row2) && (col1 === col2)) {
                if (row1 < row2) {
                    rectangle2.width = 1
                    rectangle2.height = (row2 - row1) * blockSize
                    rectangle2.opacity = 1
                    rectangle2.x = col1 * blockSize + blockSize / 2
                    rectangle2.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle2.width = 1
                    rectangle2.height = (row1 - row2) * blockSize
                    rectangle2.opacity = 1
                    rectangle2.x = col2 * blockSize + blockSize / 2
                    rectangle2.y = row2 * blockSize + blockSize / 2
                }
            }
        }
    }
    function drawline3(row1, col1, row2, col2) {
        if ((row1 === row2) || (col1 === col2)) {
            if ((row1 === row2) && (col1 !== col2)) {
                if (col1 < col2) {
                    rectangle3.width = (col2 - col1) * blockSize
                    rectangle3.height = 1
                    rectangle3.opacity = 1
                    rectangle3.x = col1 * blockSize + blockSize / 2
                    rectangle3.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle3.width = (col1 - col2) * blockSize
                    rectangle3.height = 1
                    rectangle3.opacity = 1
                    rectangle3.x = col2 * blockSize + blockSize / 2
                    rectangle3.y = row2 * blockSize + blockSize / 2
                }
            }
            if ((row1 !== row2) && (col1 === col2)) {
                if (row1 < row2) {
                    rectangle3.width = 1
                    rectangle3.height = (row2 - row1) * blockSize
                    rectangle3.opacity = 1
                    rectangle3.x = col1 * blockSize + blockSize / 2
                    rectangle3.y = row1 * blockSize + blockSize / 2
                } else {
                    rectangle3.width = 1
                    rectangle3.height = (row1 - row2) * blockSize
                    rectangle3.opacity = 1
                    rectangle3.x = col2 * blockSize + blockSize / 2
                    rectangle3.y = row2 * blockSize + blockSize / 2
                }
            }
        }
    }

    function checkNoBarrier(row1, col1, row2, col2) {
        if (row1 === row2 || col1 === col2) {
            if (!zeroTurningPoint(row1, col1, row2, col2)) {
                if (threeTurningPoint(row1, col1, row2, col2)) {
                    linelevel = 3
                    return true
                }
            } else {

                linelevel = 1
                point = [row1, col1, row2, col2]
                return true
            }
        } else {
            if (!twoTurningPoint(row1, col1, row2, col2)) {
                if (threeTurningPoint(row1, col1, row2, col2)) {
                    linelevel = 3
                    return true
                }
            } else {
                linelevel = 2
                return true
            }
        }
        linelevel = 0
        return false
    }

    function zeroTurningPoint(row1, col1, row2, col2) {
        if (row1 === row2) {
            if (col1 < col2) {
                for (var i = col1 + 1; i < col2; i++) {
                    if (gameArea3.field[index(row1, i)] !== null) {
                        return false
                    }
                }
            } else {
                for (var n = col2 + 1; n < col1; n++) {
                    if (gameArea3.field[index(row1, n)] !== null)
                        return false
                }
            }
        } else if (col1 === col2) {
            if (row1 < row2) {
                for (var j = row1 + 1; j < row2; j++) {
                    if (gameArea3.field[index(j, col1)] !== null)
                        return false
                }
            } else {
                for (var m = row2 + 1; m < row1; m++) {
                    if (gameArea3.field[index(m, col1)] !== null)
                        return false
                }
            }
        } else {
            return false
        }

        return true
    }

    function threeTurningPoint(row1, col1, row2, col2) {
        for (var i = row1 + 1; i < rows && i >= 0
             && gameArea3.field[index(i, col1)] === null; i++) {
            for (var a = row2 + 1; a < rows && a >= 0
                 && gameArea3.field[index(a, col2)] === null; a++) {
                if (zeroTurningPoint(i, col1, a, col2)) {
                    point = [row1, col1, i, col1, a, col2, row2, col2]
                    return true
                }
            }
            for (var b = row2 - 1; b < rows && b >= 0
                 && gameArea3.field[index(b, col2)] === null; b--) {
                if (zeroTurningPoint(i, col1, b, col2)) {
                    point = [row1, col1, i, col1, b, col2, row2, col2]
                    return true
                }
            }
            for (var c = col2 + 1; c < columns && c >= 0
                 && gameArea3.field[index(row2, c)] === null; c++) {
                if (zeroTurningPoint(i, col1, row2, c)) {
                    return true
                }
            }
            for (var d = col2 - 1; d < columns && d >= 0
                 && gameArea3.field[index(row2, d)] === null; d--) {
                if (zeroTurningPoint(i, col1, row2, d))
                    return true
            }
        }

        for (i = row1 - 1; i < rows && i >= 0
             && gameArea3.field[index(i, col1)] === null; i--) {
            for (a = row2 + 1; a < rows && a >= 0
                 && gameArea3.field[index(a, col2)] === null; a++) {
                if (zeroTurningPoint(i, col1, a, col2)) {
                    point = [row1, col1, i, col1, a, col2, row2, col2]
                    return true
                }
            }
            for (b = row2 - 1; b < rows && b >= 0
                 && gameArea3.field[index(b, col2)] === null; b--) {
                if (zeroTurningPoint(i, col1, b, col2)) {
                    point = [row1, col1, i, col1, b, col2, row2, col2]
                    return true
                }
            }
            for (c = col2 + 1; c < columns && c >= 0
                 && gameArea3.field[index(row2, c)] === null; c++) {
                if (zeroTurningPoint(i, col1, row2, c))
                    return true
            }
            for (d = col2 - 1; d < columns && d >= 0
                 && gameArea3.field[index(row2, d)] === null; d--) {
                if (zeroTurningPoint(i, col1, row2, d))
                    return true
            }
        }

        for (i = col1 - 1; i < columns && i >= 0
             && gameArea3.field[index(row1, i)] === null; i--) {
            for (a = row2 + 1; a < rows && a >= 0
                 && gameArea3.field[index(a, col2)] === null; a++) {
                if (zeroTurningPoint(row1, i, a, col2))
                    return true
            }
            for (b = row2 - 1; b < rows && b >= 0
                 && gameArea3.field[index(b, col2)] === null; b--) {
                if (zeroTurningPoint(row1, i, b, col2))
                    return true
            }
            for (c = col2 + 1; c < columns && c >= 0
                 && gameArea3.field[index(row2, c)] === null; c++) {
                if (zeroTurningPoint(row1, i, row2, c)) {
                    point = [row1, col1, row1, i, row2, c, row2, col2]
                    return true
                }
            }
            for (d = col2 - 1; d < columns && d >= 0
                 && gameArea3.field[index(row2, d)] === null; d--) {
                if (zeroTurningPoint(row1, i, row2, d)) {
                    point = [row1, col1, row1, i, row2, d, row2, col2]
                    return true
                }
            }
        }

        for (i = col1 + 1; i < columns && i >= 0
             && gameArea3.field[index(row1, i)] === null; i++) {
            for (a = row2 + 1; a < rows && a >= 0
                 && gameArea3.field[index(a, col2)] === null; a++) {
                if (zeroTurningPoint(row1, i, a, col2)) {
                    return true
                }
            }
            for (b = row2 - 1; b < rows && b >= 0
                 && gameArea3.field[index(b, col2)] === null; b--) {
                if (zeroTurningPoint(row1, i, b, col2))
                    return true
            }
            for (c = col2 + 1; c < columns && c >= 0
                 && gameArea3.field[index(row2, c)] === null; c++) {
                if (zeroTurningPoint(row1, i, row2, c)) {
                    point = [row1, col1, row1, i, row2, c, row2, col2]
                    return true
                }
            }
            for (d = col2 - 1; d < columns && d >= 0
                 && gameArea3.field[index(row2, d)] === null; d--) {
                if (zeroTurningPoint(row1, i, row2, d)) {
                    point = [row1, col1, row1, i, row2, d, row2, col2]
                    return true
                }
            }
        }

        return false
    }

    function twoTurningPoint(row1, col1, row2, col2) {

        if (((zeroTurningPoint(row1, col1, row1, col2))
             && (zeroTurningPoint(row1, col2, row2,
                                  col2)) && (gameArea3.field[index(
                                                                row1, col2)] === null))) {
            point = [row1, col1, row1, col2, row2, col2]
            return true
        } else if (((zeroTurningPoint(row1, col1, row2, col1))
                    && (zeroTurningPoint(row2, col1, row2,
                                         col2)) && (gameArea3.field[index(
                                                                       row2, col1)] === null))) {
            point = [row1, col1, row2, col1, row2, col2]
            return true
        }

        return false
    }


//    function matchBlock(blockB){

//        if(field1[0].row!==blockB.row && field1[0].column!==blockB.column)
//            return false
//        var min;
//        var max;
//        if(field1[0].row===blockB.row){
//            min=field1[0].column<blockB.column?field1[0].column:blockB.column;
//            max=field1[0].column>blockB.column?field1[0].column:blockB.column;
//            for(min++; min<max; min++){
//                var blockx=field[index(field1[0].row, min)]
//                if(blockx!== null)
//                    return false
//            }
//        }
//        else{
//            min=field1[0].row<blockB.row?field1[0].row:blockB.row
//            max=field1[0].row>blockB.row?field1[0].row:blockB.row
//            for(min++; min<max; min++){
//                var blocky = field[index(min, field1[0].column)]
//                if(blocky!==null)
//                    return false
//            }
//        }
//        return true
//    }


//    function matchBlockOne(blockB)
//    {
////        if(blockB.row===field1[0].row||blockB.column===field1[0].column)
////            return matchBlock(blockB)
//        var pt1 = gameArea3.field[index(field1[1].row,field1[0].column)];

//        if(pt1===null){
//            console.log("pt1 first")
//            if(
//            matchBlockC(field1[1].row,field1[0].column,field1[0].row, field1[0].column)&&
//            matchBlockC(field1[1].row,field1[0].column,field1[1].row, field1[1].column)){
//                return true
//            }
//        }

//        pt1 = gameArea3.field[index(field1[0].row, field1[1].column)];
//        if(pt1===null){
//            console.log("pt1 scenond")
//            if(
//            matchBlockC(field1[0].row,field1[1].column,field1[0].row, field1[0].column)&&
//            matchBlockC(field1[0].row,field1[1].column,field1[1].row, field1[1].column))
//                return true
//        }

//        return false
//    }

//    function matchBlockC(rowC, columnC, rowA, columnA){
//        var min;
//        var max;
//        if(columnC===columnA){
//            min=rowC<rowA?rowC:rowA;
//            max=rowC>rowA?rowC:rowA;
//            for(min++; min<max; min++){
//                var block=field[index(min, columnA)]
//                if(block!==null)
//                    return false
//            }
//        }
//        if(rowC===rowA){
//            min=columnC<columnA?columnC:columnA;
//            max=columnC>columnA?columnC:columnA;
//            for(min++; min<max; min++){
//                var blocky = field[index(rowA, min)]
//                if(blocky!==null)
//                    return false
//            }
//        }
//        return true

//    }


//    function matchBlockTow(blockB){

////        matchBlock(blockB)

//        console.log("enter matchBlockTow")

////        for(var i=field1[0]+1;)
//        if(blockB.row===field1[0].row||blockB.column===field1[0].column)
//            return matchBlock(blockB)

//        //向右搜索
//        var right=1;
//        var blockright = field[index(field1[0].row, field1[0].column+right)]

//        console.log(blockright)

//        while(blockright===null){
////            console.log(blockC)
//            if(matchBlockOne(blockright)){
//                return true
//            }
//            right++;
//            blockright=field[index(field1[0].row, field1[0].column+right)]
//        }
//        console.log("NO WHILE")

//        //向左搜索
//        var left=1
//        var blockleft = field[index(field1[0].row, field1[0].column-left)]
//        while(blockleft===null){
//            if(matchBlockOne(blockleft)){
//                return true
//            }
//            left++;
//            blockleft = field[index(field1[0].row, field1[0].column-left)]
//        }

//        //向上搜索
//        var up=1
//        var blockup=field[index(field1[0].row-up, field1[0].column)]
//        while(blockup===null){
//            if(matchBlockOne(blockup)){
//                return true
//            }
//            up++
//            blockup = field[index(field1[0].row-up, field1[0].column)]
//        }

//        //向下搜索
//        var down=1
//        var blockdown=field[index(field1[0].row+down, field1[0].column)]
//        while(blockdown===null){
//            if(matchBlockOne(blockdown)){
//                return true
//            }
//            down++;
//            blockdown=field[index(field1[0].row+down, field1[0].column)]
//        }

//    }
//    function matchBlockOne1(blockrlud)
//    {
//        var blockm=field[index(field1[i].row,blockrlud.column)]
//        if(blockm===null){
//            if(
//            matchBlockC(field1[i].row,blockrlud.column,blockrlud.row, blockrlud.column)&&
//            matchBlockC(field1[i].row,blockrlud.column,field1[1].row, field1[1].column)){
//                return true
//            }
//        }
//    }
}







