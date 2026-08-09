#include "ReviewController.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>

ReviewController::ReviewController(QObject *parent) : QObject(parent) {
    m_tickTimer.setInterval(50);
    connect(&m_tickTimer, &QTimer::timeout, this, &ReviewController::reviewTimeChanged);
}

qint64 ReviewController::reviewTimeMs() const {
    return m_recording ? m_timer.elapsed() : m_stoppedReviewTimeMs;
}

void ReviewController::startReview(qint64 sourceTimeMs) {
    m_events = QJsonArray{};
    m_stoppedReviewTimeMs = 0;
    m_timer.restart();
    m_recording = true;
    m_tickTimer.start();
    emit recordingChanged();
    addEvent("review_start", sourceTimeMs);
}

void ReviewController::stopReview(qint64 sourceTimeMs) {
    if (!m_recording) return;
    addEvent("review_stop", sourceTimeMs);
    m_stoppedReviewTimeMs = m_timer.elapsed();
    m_recording = false;
    m_tickTimer.stop();
    emit recordingChanged();
    emit reviewTimeChanged();
}

void ReviewController::addEvent(const QString &type, qint64 sourceTimeMs, const QVariantMap &payload) {
    if (!m_recording && type != "review_start") return;

    QJsonObject obj;
    obj["type"] = type;
    obj["reviewTimeMs"] = static_cast<qint64>(reviewTimeMs());
    obj["sourceTimeMs"] = sourceTimeMs;
    obj["payload"] = QJsonObject::fromVariantMap(payload);
    m_events.append(obj);
    emit eventsChanged();
}

void ReviewController::clear() {
    m_recording = false;
    m_tickTimer.stop();
    m_stoppedReviewTimeMs = 0;
    m_events = QJsonArray{};
    emit recordingChanged();
    emit reviewTimeChanged();
    emit eventsChanged();
}

bool ReviewController::saveToFile(const QString &filePath) const {
    QFile f(filePath);
    if (!f.open(QIODevice::WriteOnly)) return false;

    QJsonObject root;
    root["version"] = "0.0.1";
    root["reviewDurationMs"] = static_cast<qint64>(reviewTimeMs());
    root["events"] = m_events;
    f.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    return true;
}
