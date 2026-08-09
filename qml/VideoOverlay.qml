import QtQuick

Item {
    id: root
    property string tool: "draw"
    property color strokeColor: "#ff453a"
    property real strokeWidth: 4
    signal annotationCreated(string type, var data)

    Canvas {
        id: canvas
        anchors.fill: parent
        property var strokes: []
        property var activePoints: []

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            for (let s of strokes) {
                ctx.strokeStyle = s.color
                ctx.lineWidth = s.width
                ctx.beginPath()

                if (s.type === "draw") {
                    if (s.points.length === 0) continue
                    ctx.moveTo(s.points[0].x * width, s.points[0].y * height)
                    for (let i = 1; i < s.points.length; i++)
                        ctx.lineTo(s.points[i].x * width, s.points[i].y * height)
                    ctx.stroke()
                } else if (s.type === "circle") {
                    const x1 = s.start.x * width
                    const y1 = s.start.y * height
                    const x2 = s.end.x * width
                    const y2 = s.end.y * height
                    const rx = Math.abs(x2 - x1) / 2
                    const ry = Math.abs(y2 - y1) / 2
                    const cx = (x1 + x2) / 2
                    const cy = (y1 + y2) / 2
                    ctx.ellipse(cx, cy, rx, ry, 0, 0, Math.PI * 2)
                    ctx.stroke()
                } else if (s.type === "arrow") {
                    const x1 = s.start.x * width
                    const y1 = s.start.y * height
                    const x2 = s.end.x * width
                    const y2 = s.end.y * height
                    ctx.moveTo(x1, y1)
                    ctx.lineTo(x2, y2)
                    ctx.stroke()
                    const angle = Math.atan2(y2-y1, x2-x1)
                    const head = 16
                    ctx.beginPath()
                    ctx.moveTo(x2, y2)
                    ctx.lineTo(x2-head*Math.cos(angle-Math.PI/6), y2-head*Math.sin(angle-Math.PI/6))
                    ctx.moveTo(x2, y2)
                    ctx.lineTo(x2-head*Math.cos(angle+Math.PI/6), y2-head*Math.sin(angle+Math.PI/6))
                    ctx.stroke()
                }
            }

            if (activePoints.length > 1 && root.tool === "draw") {
                ctx.strokeStyle = root.strokeColor
                ctx.lineWidth = root.strokeWidth
                ctx.beginPath()
                ctx.moveTo(activePoints[0].x * width, activePoints[0].y * height)
                for (let j = 1; j < activePoints.length; j++)
                    ctx.lineTo(activePoints[j].x * width, activePoints[j].y * height)
                ctx.stroke()
            }
        }

        function undo() {
            if (strokes.length === 0) return
            strokes = strokes.slice(0, -1)
            requestPaint()
        }

        function clearAll() {
            strokes = []
            activePoints = []
            requestPaint()
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            property point startPoint

            onPressed: mouse => {
                startPoint = Qt.point(mouse.x / width, mouse.y / height)
                if (root.tool === "draw") {
                    canvas.activePoints = [ {x: startPoint.x, y: startPoint.y} ]
                    canvas.requestPaint()
                }
            }

            onPositionChanged: mouse => {
                if (!pressed || root.tool !== "draw") return
                let p = canvas.activePoints.slice()
                p.push({x: mouse.x / width, y: mouse.y / height})
                canvas.activePoints = p
                canvas.requestPaint()
            }

            onReleased: mouse => {
                const endPoint = Qt.point(mouse.x / width, mouse.y / height)
                let stroke
                if (root.tool === "draw") {
                    stroke = { type: "draw", points: canvas.activePoints, color: root.strokeColor.toString(), width: root.strokeWidth }
                    canvas.activePoints = []
                } else {
                    stroke = { type: root.tool,
                               start: {x:startPoint.x, y:startPoint.y},
                               end: {x:endPoint.x, y:endPoint.y},
                               color: root.strokeColor.toString(), width: root.strokeWidth }
                }
                canvas.strokes = canvas.strokes.concat([stroke])
                canvas.requestPaint()
                root.annotationCreated(root.tool, stroke)
            }
        }
    }

    function undo() { canvas.undo() }
    function clearAll() { canvas.clearAll() }
}
