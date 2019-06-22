#ifndef GAMEDATA_H
#define GAMEDATA_H

#include <QObject>
#include <QJsonObject>

class GameData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int demoCount READ demoCount WRITE setDemoCount NOTIFY demoCountChanged)
    Q_PROPERTY(int score READ score WRITE setScore NOTIFY scoreChanged)
    Q_PROPERTY(int remainedTime READ remainedTime WRITE setRemainedTime NOTIFY remainedTimeChanged)

public:
    GameData();

    int demoCount() const;
    void setDemoCount(const int count);

    int score() const;
    void setScore(const int score);

    int remainedTime() const;
    void setRemainedTime (const int remainedTime);

    void read(const QJsonObject &json);
    void write(QJsonObject &json);

    Q_INVOKABLE bool load();
    Q_INVOKABLE bool save();

signals:
    void demoCountChanged();
    void scoreChanged();
    void remainedTimeChanged();

private:
    int m_demoCount;
    int m_score;
    int m_remainedTime;
};

#endif // GAMEDATA_H
