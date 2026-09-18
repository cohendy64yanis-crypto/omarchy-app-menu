import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui

Panel {
    id: root
    moduleName: "io.github.cohendy64yanis-crypto.app-menu"
    manageIpc: false

    property var anchorItem: null
    property var hostWidget: null

    function open() { root.controller.show() }
    function close() { root.controller.hide() }
    function toggle() { root.opened ? root.close() : root.open() }

    KeyboardPanel {
        id: panel
        anchorItem: root.anchorItem
        owner: root.hostWidget || root
        bar: root.bar
        open: root.opened
        focusTarget: keyCatcher

        // Taille de la fenêtre volante
        contentWidth: 320
        contentHeight: 400

        PanelKeyCatcher {
            id: keyCatcher
            anchors.fill: parent
            onCloseRequested: root.close()

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Text {
                    text: "Créer un nouveau menu"
                    font.bold: true
                    color: "white"
                }

                TextField {
                    id: menuNameInput
                    Layout.fillWidth: true
                    placeholderText: "Nom du menu (ex: Jeux, Dev...)"
                }

                Text {
                    text: "Sélectionne les applications :"
                    color: "lightgray"
                }

                // Liste provisoire pour la structure visuelle
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        model: ["Terminal", "Navigateur", "Discord", "Geometry Dash", "Editeur de texte"]
                        delegate: CheckBox {
                            text: modelData
                            // Le style s'adaptera au thème d'Omarchy
                        }
                    }
                }

                Button {
                    text: "Sauvegarder"
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        console.log("Menu " + menuNameInput.text + " sauvegardé.")
                        root.close()
                    }
                }
            }
        }
    }
}
