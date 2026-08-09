#pragma once

#include <QObject>
#include <QElapsedTimer>
#include <QJsonArray>
#include <QVariantMap>
#include <QTimer>

class ReviewController : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool recording READ recording NOTIFY recordingChanged)
    Q_PROPERTY(qint64 reviewTimeMs READ reviewTimeMs NOTIFY reviewTimeChanged)
    Q_PROPERTY(QJsonArray events READ events NOTIFY eventsChanged)

public:
    explicit ReviewController(QObject *parent = nullptr);

    bool recording() const { return m_recording; }
    qint64 reviewTimeMs() const;
    QJsonArray events() const { return m_events; }

    Q_INVOKABLE void startReview(qint64 sourceTimeMs);
    Q_INVOKABLE void stopReview(qint64 sourceTimeMs);
    Q_INVOKABLE void addEvent(const QString &type, qint64 sourceTimeMs, const QVariantMap &payload = {});
    Q_INVOKABLE void clear();
    Q_INVOKABLE bool saveToFile(const QString &filePath) const;

signals:
    void recordingChanged();
    void reviewTimeChanged();
    void eventsChanged();

private:
    bool m_recording = false;
    QElapsedTimer m_timer;
    qint64 m_stoppedReviewTimeMs = 0;
    QJsonArray m_events;
    QTimer m_tickTimer;
};
