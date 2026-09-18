import QtQuick
import Quickshell
import qs.Ui

BarWidget {
    id: root
    moduleName: "io.github.cohendy64yanis-crypto.app-menu"

    // La taille du widget copie strictement celle du bouton. Zéro ambiguïté.
    implicitWidth: addBtn.implicitWidth
    implicitHeight: addBtn.implicitHeight

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

    // Le bouton s'affiche directement
    WidgetButton {
        id: addBtn
        text: "+ Add the app"
        tooltipText: "Créer un nouveau menu d'applications"
        anchors.fill: parent
        
        onPressed: function(buttonCode) {
            if (buttonCode === Qt.LeftButton) root.toggle()
        }
    }

    // Le panneau est chargé discrètement
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
