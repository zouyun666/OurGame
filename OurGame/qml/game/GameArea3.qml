import QtQuick 2.0

Item {

    id: gameArea

    width: blockSize * 8
    height: blockSize * 12
    // 隐藏和禁用不透明度
    visible: gameArea.opacity > 0
    enabled: gameArea.opacity == 1
    property double blockSize
    property int rows: Math.floor(height/blockSize)
    property int columns: Math.floor(width/blockSize)
    property var field:[]
    property int maxTypes
    property int clicks
    property bool isSelected: false

    property var field1:[]
    signal initFinished3()
    signal gameOver()

    function index(row, column){
        return row * columns + column
    }

    function initializeField(){

        gameArea.clicks=0
        gameArea.maxTypes=8

        clearField()

        for(var i=0; i<rows; i++){
            for(var j=0; j<columns; j++){
//                if(j>2&&i>2||j<2&&i<5){
                    gameArea.field[index(i, j)] = createBlock(i, j)
//                }else{
//                    gameArea.field[index(i,j)]=null
//                    console.log(field[index(i,j)])
//                }
            }
        }

        initFinished3()
    }

    function clearField(){
        for(var i=0; i<gameArea.field.length;i++){
            var block = gameArea.field[i]
            if(block !== null){
                entityManager3.removeEntityById(block.entityId)
            }
        }
        gameArea.field = []
    }

    function createBlock(row, column){
        var entityProperties = {
            width: blockSize,
            height: blockSize,
            x: column * blockSize,
            y: row * blockSize,
            type: Math.floor(Math.random()*gameArea.maxTypes),//只有5种水果
            row: row,
            column: column,
            selected: 0
        }
        var id = entityManager3.createEntityFromUrlWithProperties(Qt.resolvedUrl("Block3.qml"), entityProperties)

        var entity = entityManager3.getEntityById(id)
//        entity.selection.connect(changseleced)
        entity.clicked.connect(handleClick)

        return entity
    }


//    var block1;
//    var block2;
    function handleClick(row, column, type)
    {
        gameArea.clicks++;
        console.log("handleClick")
        var blockA;
        var blockB;
        var fieldCopy=field.slice()
        console.log(gameArea.clicks)
        if(gameArea.clicks%2 !== 0){
            blockA=field[index(row,column)];
//            fieldCopy[index(row,column)]=null
//            console.log(field[index(row, column)]);
            console.log("ROW:"+blockA.row)
            console.log("COLUMN:"+blockA.column)
            field1[0]=blockA
//            entityManager.removeEntityById(blockA.entityId)
        }

        if(gameArea.clicks%2===0){
            blockB=field[index(row,column)];
//            fieldCopy[index(row,column)]=null
//            console.log(field[index(row, column)]);
            console.log("ROW:"+blockB.row)
            console.log("COLUMN:"+blockB.column)
            field1[1]=blockB

                if(blockB.type===field1[0].type && matchBlockTow(blockB)){
                    entityManager3.removeEntityById(blockB.entityId)
                    entityManager3.removeEntityById(field1[0].entityId)
                    field[index(field1[0].row, field1[0].column)]=null
                    field[index(field1[1].row, field1[1].column)]=null
                    var score=(clicks+1)/2*4
                    scene.score+=score
                }
//            }
        }

    }


    function matchBlock(blockB){

        if(field1[0].row!==blockB.row && field1[0].column!==blockB.column)
            return false
        var min;
        var max;
        if(field1[0].row===blockB.row){
            min=field1[0].column<blockB.column?field1[0].column:blockB.column;
            max=field1[0].column>blockB.column?field1[0].column:blockB.column;
            for(min++; min<max; min++){
                var blockx=field[index(field1[0].row, min)]
                if(blockx!== null)
                    return false
            }
        }
        else{
            min=field1[0].row<blockB.row?field1[0].row:blockB.row
            max=field1[0].row>blockB.row?field1[0].row:blockB.row
            for(min++; min<max; min++){
                var blocky = field[index(min, field1[0].column)]
                if(blocky!==null)
                    return false
            }
        }
        return true
    }


    function matchBlockOne(blockB)
    {
//        if(blockB.row===field1[0].row||blockB.column===field1[0].column)
//            return matchBlock(blockB)
        var pt1 = gameArea.field[index(field1[1].row,field1[0].column)];
        console.log(field1[1].row)
        console.log(field1[0].column)
        console.log(field[index(field1[1].row,field1[0].column)])
        console.log(pt1)
        console.log("-------------------------------------")
        console.log("Crow:"+field1[1].row+ "             Ccolumn:"+field1[0].column)
        console.log("Crow:"+field1[0].row+ "             Ccolumn:"+field1[1].column)

        if(pt1===null){
            console.log("pt1 first")
            if(
            matchBlockC(field1[1].row,field1[0].column,field1[0].row, field1[0].column)&&
            matchBlockC(field1[1].row,field1[0].column,field1[1].row, field1[1].column)){
                return true
            }
        }

        pt1 = gameArea.field[index(field1[0].row, field1[1].column)];
        if(pt1===null){
            console.log("pt1 scenond")
            if(
            matchBlockC(field1[0].row,field1[1].column,field1[0].row, field1[0].column)&&
            matchBlockC(field1[0].row,field1[1].column,field1[1].row, field1[1].column))
                return true
        }

        return false
    }

    function matchBlockC(rowC, columnC, rowA, columnA){
        var min;
        var max;
        if(columnC===columnA){
            min=rowC<rowA?rowC:rowA;
            max=rowC>rowA?rowC:rowA;
            for(min++; min<max; min++){
                var block=field[index(min, columnA)]
                if(block!==null)
                    return false
            }
        }
        if(rowC===rowA){
            min=columnC<columnA?columnC:columnA;
            max=columnC>columnA?columnC:columnA;
            for(min++; min<max; min++){
                var blocky = field[index(rowA, min)]
                if(blocky!==null)
                    return false
            }
        }
        return true

    }

    function matchBlockTow(blockB){

        console.log("enter matchBlockTow")

//        for(var i=field1[0]+1;)
        if(blockB.row===field1[0].row||blockB.column===field1[0].column)
            return matchBlock(blockB)

        //向右搜索
        var right=1;
        var blockright = field[index(field1[0].row, field1[0].column+right)]

        console.log(blockright)

        while(blockright===null){
//            console.log(blockC)
            if(matchBlockOne(blockright)){
                return true
            }
            right++;
            blockright=field[index(field1[0].row, field1[0].column+right)]
        }
        console.log("NO WHILE")

        //向左搜索
        var left=1
        var blockleft = field[index(field1[0].row, field1[0].column-left)]
        while(blockleft===null){
            if(matchBlockOne(blockleft)){
                return true
            }
            left++;
            blockleft = field[index(field1[0].row, field1[0].column-left)]
        }

        //向上搜索
        var up=1
        var blockup=field[index(field1[0].row-up, field1[0].column)]
        while(blockup===null){
            if(matchBlockOne(blockup)){
                return true
            }
            up++
            blockup = field[index(field1[0].row-up, field1[0].column)]
        }

        //向下搜索
        var down=1
        var blockdown=field[index(field1[0].row+down, field1[0].column)]
        while(blockdown===null){
            if(matchBlockOne(blockdown)){
                return true
            }
            down++;
            blockdown=field[index(field1[0].row+down, field1[0].column)]
        }

    }
    function matchBlockOne1(blockrlud)
    {
        var blockm=field[index(field1[i].row,blockrlud.column)]
        if(blockm===null){
            if(
            matchBlockC(field1[i].row,blockrlud.column,blockrlud.row, blockrlud.column)&&
            matchBlockC(field1[i].row,blockrlud.column,field1[1].row, field1[1].column)){
                return true
            }
        }
        }

    }





