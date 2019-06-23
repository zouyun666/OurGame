#include "gamedata.h"
#include <QFile>
#include <QJsonDocument>

GameData::GameData(){}

int GameData::demoCount() const     //getter
{
    return m_demoCount;
}

void GameData::setDemoCount(const int count)    //setter
{
    m_demoCount = count;
}

int GameData::score() const     //getter
{
    return m_score;
}

void GameData::setScore(const int score)        //setter
{
    m_score = score;
}

int GameData::remainedTime() const      //getter
{
    return m_remainedTime;
}

void GameData::setRemainedTime(const int remainedTime)     //setter
{
    m_remainedTime = remainedTime;
}

void GameData::read(const QJsonObject &json)
{
    //判断得到的json对象中是否包含相应的键，如果包含，就将其注入到数据成员中
    if(json.contains("demoCount") && json["demoCount"].isDouble())
        m_demoCount = json["demoCount"].toInt();

    if(json.contains("score") && json["score"].isDouble())
        m_score = json["score"].toInt();

    if(json.contains("remainedTime") && json["remainedTime"].isDouble())
        m_remainedTime = json["remainedTime"].toInt();
}

void GameData::write(QJsonObject &json)
{
    json["demoCount"] = m_demoCount;
    json["score"] = m_score;
    json["remainedTime"] = m_remainedTime;
}

bool GameData::load()
{
    //导入json数据文件
    QFile loadFile(QStringLiteral("save.json"));

    if(!loadFile.open(QIODevice::ReadOnly)){
        qWarning("Couldn't open file.");
        return false;
    }
    //读取
    QByteArray saveData = loadFile.readAll();//将导入的数据以json文档的形式组织
    QJsonDocument loadDoc( QJsonDocument::fromJson(saveData) );//通过文档得到这个json对象
    QJsonObject json(loadDoc.object());
    read(json); //将json对象中的数据读入类的数据成员中。
    return true;
}

bool GameData::save()
{
    QFile saveFile(QStringLiteral("save.json"));
    if(!saveFile.open(QIODevice::WriteOnly)){
        qWarning("Couldn't save file.");
                 return false;
    }
    QJsonObject gameObject;
    write(gameObject);//将数据成员保存在json中
    QJsonDocument saveDoc(gameObject);//将这个json的对象变成文档
    saveFile.write(saveDoc.toJson());//将这个文档以json的形式写入save.json
    return true;
}
