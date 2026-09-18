import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Ui

BarWidget {
    id: root
    moduleName: "io.github.cohendy64yanis-crypto.app-menu"

    // Permet de savoir si le panneau est ouvert
    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

    function open() { if (panelLoader.item) panelLoader.item.open() }
    function close() { if (panelLoader.item) panelLoader.item.close() }
    function toggle() { if (panelLoader.item) panelLoader.item.toggle() }

    // Connecte le panneau volant au bouton de la barre
    function injectPanel() {
        if (!panelLoader.item) return
        panelLoader.item.bar = root.bar
        panelLoader.item.anchorItem = addBtn
        panelLoader.item.hostWidget = root
    }

    onBarChanged: injectPanel()

    // Charge le fichier Panel.qml en arrière-plan
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

    // L'interface visible dans ta barre à gauche
    RowLayout {
        anchors.fill: parent
        spacing: 4

        // Espace où les menus déroulants créés s'afficheront plus tard
        
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
