import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtMultimedia

ApplicationWindow {
    id: window
    width: 1440
    height: 900
    visible: true
    title: "VOLLEY VIDEO LAB — Prototype 0.0.1"

    property string activeTool: "draw"

    MediaPlayer {
        id: player
        videoOutput: videoOutput
        audioOutput: AudioOutput { volume: 1.0 }
        onPlaybackStateChanged: {
            if (reviewController.recording) {
                reviewController.addEvent(playbackState === MediaPlayer.PlayingState ? "play" : "pause", position)
            }
        }
        onPlaybackRateChanged: {
            if (reviewController.recording)
                reviewController.addEvent("speed_change", position, {"speed": playbackRate})
        }
    }

    FileDialog {
        id: openVideoDialog
        title: "Открыть видео"
        nameFilters: ["Video files (*.mp4 *.mov *.mkv *.avi *.m4v)", "All files (*)"]
        onAccepted: player.source = selectedFile
    }

    FileDialog {
        id: saveReviewDialog
        title: "Сохранить Review JSON"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Volley Review (*.json)"]
        onAccepted: reviewController.saveToFile(selectedFile.toString().replace("file://", ""))
    }

    Shortcut { sequence: "Space"; onActivated: togglePlay() }
    Shortcut { sequence: "Shift+Left"; onActivated: seekBy(-5000) }
    Shortcut { sequence: "Shift+Right"; onActivated: seekBy(5000) }
    Shortcut { sequence: "R"; onActivated: toggleReview() }
    Shortcut { sequence: "Ctrl+Z"; onActivated: overlay.undo() }

    function togglePlay() {
        if (player.playbackState === MediaPlayer.PlayingState) player.pause(); else player.play()
    }
    function seekBy(delta) {
        const from = player.position
        player.position = Math.max(0, Math.min(player.duration, from + delta))
        if (reviewController.recording)
            reviewController.addEvent("seek", player.position, {"fromMs": from, "toMs": player.position})
    }
    function frameBy(frames) {
        const fps = 60.0 // prototype assumption; replace with probed media fps
        const from = player.position
        player.pause()
        player.position = Math.max(0, from + Math.round(1000 / fps) * frames)
        if (reviewController.recording)
            reviewController.addEvent("frame_step", player.position, {"frames": frames})
    }
    function toggleReview() {
        if (reviewController.recording) reviewController.stopReview(player.position)
        else reviewController.startReview(player.position)
    }
    function fmt(ms) {
        let total = Math.max(0, Math.floor(ms / 1000))
        let h = Math.floor(total / 3600)
        let m = Math.floor((total % 3600) / 60)
        let s = total % 60
        let milli = Math.floor(ms % 1000)
        function p2(v){ return (v < 10 ? "0" : "") + v }
        function p3(v){ return (v < 10 ? "00" : v < 100 ? "0" : "") + v }
        return p2(h)+":"+p2(m)+":"+p2(s)+"."+p3(milli)
    }

    Rectangle {
        anchors.fill: parent
        color: "#101217"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Label { text: "VOLLEY VIDEO LAB"; font.pixelSize: 22; font.bold: true; color: "white" }
                Label { text: "Prototype 0.0.1"; color: "#8f96a3" }
                Item { Layout.fillWidth: true }
                Button { text: "Открыть видео"; onClicked: openVideoDialog.open() }
                Button { text: "Сохранить Review"; enabled: reviewController.events.length > 0; onClicked: saveReviewDialog.open() }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "black"
                clip: true

                VideoOutput {
                    id: videoOutput
                    anchors.fill: parent
                    fillMode: VideoOutput.PreserveAspectFit
                }

                VideoOverlay {
                    id: overlay
                    anchors.fill: parent
                    tool: activeTool
                    onAnnotationCreated: (type, data) => {
                        if (reviewController.recording)
                            reviewController.addEvent("annotation_add", player.position, {"annotationType": type, "data": data})
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 12
                    radius: 6
                    color: "#99000000"
                    visible: reviewController.recording
                    width: recRow.implicitWidth + 20
                    height: recRow.implicitHeight + 12
                    Row {
                        id: recRow
                        anchors.centerIn: parent
                        spacing: 8
                        Rectangle { width: 10; height: 10; radius: 5; color: "#ff453a" }
                        Text { text: "REC " + fmt(reviewController.reviewTimeMs); color: "white"; font.bold: true }
                    }
                }
            }

            Slider {
                Layout.fillWidth: true
                from: 0
                to: Math.max(1, player.duration)
                value: player.position
                onMoved: {
                    const old = player.position
                    player.position = value
                    if (reviewController.recording)
                        reviewController.addEvent("seek", player.position, {"fromMs": old, "toMs": player.position})
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label { text: "SOURCE  " + fmt(player.position) + " / " + fmt(player.duration); color: "white" }
                Item { Layout.fillWidth: true }
                Label { text: "REVIEW  " + fmt(reviewController.reviewTimeMs); color: reviewController.recording ? "#ff7068" : "#aeb5c0"; font.bold: true }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8
                Button { text: "−5 сек"; onClicked: seekBy(-5000) }
                Button { text: "◀ кадр"; onClicked: frameBy(-1) }
                Button { text: player.playbackState === MediaPlayer.PlayingState ? "Пауза" : "▶ Play"; onClicked: togglePlay() }
                Button { text: "кадр ▶"; onClicked: frameBy(1) }
                Button { text: "+5 сек"; onClicked: seekBy(5000) }
                Button { text: "0.5×"; checkable: true; checked: player.playbackRate === 0.5; onClicked: player.playbackRate = 0.5 }
                Button { text: "1×"; checkable: true; checked: player.playbackRate === 1.0; onClicked: player.playbackRate = 1.0 }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Button { text: "✏ Рисовать"; checkable: true; checked: activeTool === "draw"; onClicked: activeTool = "draw" }
                Button { text: "➜ Стрелка"; checkable: true; checked: activeTool === "arrow"; onClicked: activeTool = "arrow" }
                Button { text: "○ Игрок"; checkable: true; checked: activeTool === "circle"; onClicked: activeTool = "circle" }
                Button { text: "↶ Undo"; onClicked: overlay.undo() }
                Button { text: "Очистить"; onClicked: overlay.clearAll() }
                Item { Layout.fillWidth: true }
                Button {
                    text: reviewController.recording ? "■ ЗАВЕРШИТЬ" : "🔴 НАЧАТЬ РАЗБОР"
                    highlighted: true
                    onClicked: toggleReview()
                }
            }
        }
    }
}
