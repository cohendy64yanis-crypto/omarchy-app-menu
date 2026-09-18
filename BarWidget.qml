import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
    id: root
    moduleName: "io.github.cohendy64yanis-crypto.app-menu"

    property string menuName: "+ Add the app"

    Process {
        id: loadConfigProcess
        command: ["sh", "-c", "cat ~/.config/omarchy/app-menus/current.json 2>/dev/null || echo '{\"name\":\"+ Add the app\",\"apps\":[]}'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    var json = JSON.parse(data.trim());
                    if (json.name) root.menuName = json.name;
                } catch(e) {}
            }
        }
    }

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

    function open() { if (panelLoader.item) panelLoader.item.open() }
    function close() { if (panelLoader.item) panelLoader.item.close() }
    function toggle() { if (panelLoader.item) panelLoader.item.toggle() }

    function injectPanel() {
        if (!panelLoader.item) return
        panelLoader.item.bar = root.bar
        panelLoader.item.anchorItem = button
        panelLoader.item.hostWidget = root
    }

    onBarChanged: injectPanel()

    WidgetButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        text: root.menuName
        tooltipText: "Menu d'applications"
        onPressed: function(buttonCode) {
            if (buttonCode === Qt.LeftButton) root.toggle()
        }
    }

    Loader {
        id: panelLoader
        active: true
        source: Qt.resolvedUrl("Panel.qml")
        visible: false
        onLoaded: {
            root.injectPanel()
            Qt.callLater(root.injectPanel)
        }
    }
}
