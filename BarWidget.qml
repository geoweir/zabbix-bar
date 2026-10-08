import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "local.zabbix-problems"

  property string label: "0/0/0/0"
  property string status: "Not refreshed yet"
  property bool configured: false
  property bool healthy: true
  property int disaster: 0
  property int high: 0
  property int average: 0
  property int warning: 0
  property string lastUpdated: ""
  property bool detailsOpen: false
  readonly property int refreshSeconds: Math.max(15, parseInt(setting("refreshSeconds", 60), 10) || 60)
  readonly property string scriptPath: String(Qt.resolvedUrl("zabbix-counts")).replace(/^file:\/\//, "")
  readonly property var severityRows: [
    { name: "Disaster", value: disaster },
    { name: "High", value: high },
    { name: "Average", value: average },
    { name: "Warning", value: warning }
  ]

  function refresh() {
    if (!countProc.running) countProc.running = true
  }

  function openZabbix() {
    if (root.bar) root.bar.run(root.scriptPath + " --open-url")
  }

  function close() {
    detailsOpen = false
  }

  function toggleDetails() {
    detailsOpen = !detailsOpen
  }

  visible: true
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: countProc
    command: [root.scriptPath]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var raw = String(text || "").trim()
        if (!raw) {
          root.healthy = false
          root.status = "Zabbix: no response"
          return
        }

        try {
          var parsed = JSON.parse(raw)
          root.label = parsed.text || "0/0/0/0"
          var counts = parsed.counts || {}
          root.disaster = counts.disaster || 0
          root.high = counts.high || 0
          root.average = counts.average || 0
          root.warning = counts.warning || 0
          root.configured = parsed.configured === true
          root.healthy = parsed.ok === true
          root.status = root.configured
            ? (parsed.message || (root.healthy ? "Zabbix Problems" : "Zabbix API error"))
            : (parsed.message || "Zabbix is not configured")
          root.lastUpdated = Qt.formatTime(new Date(), "HH:mm:ss")
        } catch (e) {
          root.healthy = false
          root.status = "Zabbix: invalid helper response"
        }
      }
    }
  }

  Timer {
    interval: root.refreshSeconds * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.label
    active: false
    foreground: "#000000"
    activeColor: foreground
    useActiveColor: false
    slotSize: Style.space(82)
    fontSize: Style.font.caption
    tooltipText: ""
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.refresh()
      else root.toggleDetails()
    }
  }

  PopupCard {
    id: hoverCard
    anchorItem: button
    bar: root.bar
    owner: root
    triggerMode: "click"
    open: root.detailsOpen
    contentWidth: Style.space(280)
    contentHeight: details.implicitHeight + padding * 2

    Column {
      id: details
      width: parent.width
      spacing: Style.space(10)

      Text {
        width: parent.width
        text: "Zabbix Problems"
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.bold: true
        renderType: Text.NativeRendering
        elide: Text.ElideRight
      }

      Text {
        width: parent.width
        text: root.status
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
        renderType: Text.NativeRendering
        wrapMode: Text.WordWrap
      }

      Column {
        width: parent.width
        spacing: Style.space(6)

        Repeater {
          model: root.severityRows

          Row {
            width: parent.width
            height: Math.max(countText.implicitHeight, nameText.implicitHeight)
            spacing: Style.space(10)

            Rectangle {
              width: Style.space(8)
              height: Style.space(8)
              radius: width / 2
              color: Color.popups.text
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              id: nameText
              width: parent.width - countText.width - Style.space(28)
              text: modelData.name
              color: Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              renderType: Text.NativeRendering
              elide: Text.ElideRight
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              id: countText
              width: Style.space(44)
              text: String(modelData.value)
              color: Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              horizontalAlignment: Text.AlignRight
              renderType: Text.NativeRendering
              anchors.verticalCenter: parent.verticalCenter
            }
          }
        }
      }

      Text {
        width: parent.width
        text: root.lastUpdated ? ("Updated " + root.lastUpdated) : "Not refreshed yet"
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
        renderType: Text.NativeRendering
        wrapMode: Text.WordWrap
      }

      Row {
        width: parent.width
        height: Math.max(refreshHint.implicitHeight, refreshButton.height, openButton.height)
        spacing: Style.space(8)

        Text {
          id: refreshHint
          width: parent.width - refreshButton.width - openButton.width - parent.spacing * 2
          text: "Right-click the bar item, or click refresh here."
          color: Color.popups.text
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          renderType: Text.NativeRendering
          wrapMode: Text.WordWrap
          anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
          id: refreshButton
          width: Style.space(30)
          height: Style.space(26)
          radius: Style.cornerRadius
          color: refreshMouse.containsMouse ? Style.hoverFill : Style.normalFill
          border.width: Style.normalBorderWidth
          border.color: refreshMouse.containsMouse ? Style.hoverBorderColor : Style.normalBorderColor

          Text {
            anchors.centerIn: parent
            text: "\uf021"
            color: Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.iconSmall
            renderType: Text.NativeRendering
          }

          MouseArea {
            id: refreshMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.refresh()
          }
        }

        Rectangle {
          id: openButton
          width: Style.space(30)
          height: Style.space(26)
          radius: Style.cornerRadius
          color: openMouse.containsMouse ? Style.hoverFill : Style.normalFill
          border.width: Style.normalBorderWidth
          border.color: openMouse.containsMouse ? Style.hoverBorderColor : Style.normalBorderColor

          Text {
            anchors.centerIn: parent
            text: "🌐"
            color: Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            renderType: Text.NativeRendering
          }

          MouseArea {
            id: openMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openZabbix()
          }
        }
      }
    }
  }
}
