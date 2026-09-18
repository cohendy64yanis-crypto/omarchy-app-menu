import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Ui

BarWidget {
    id: root
    moduleName: "io.github.cohendy64yanis-crypto.app-menu"

    // La correction est ici : on donne une taille au widget pour qu'il soit visible
    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

    function open() { if (panelLoader.item) panelLoader.item.open() }
    function close() { if (panelLoader.item) panelLoader.item.close() }
    function toggle() { if (panelLoader.item) panelLoader.item.toggle() }

    function injectPanel() {
        if (!panelLoader.item) return
        panelLoader.item.bar = root.bar
        panelLoader.item.anchorItem = addBtn
        panelLoader.item.hostWidget = root
    }

    onBarChanged: injectPanel()

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

    RowLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 4
        
        WidgetButton {
            id: addBtn
            text: "+ Add the app"
            tooltipText: "Créer un nouveau menu d'applications"
            onPressed: function(buttonCode) {
                if (buttonCode === Qt.LeftButton) root.toggle()
            }
        }
    }
}
