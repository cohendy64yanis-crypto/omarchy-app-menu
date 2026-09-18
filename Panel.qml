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

    KeyboardPanel {
        id: panel
        anchorItem: root.anchorItem
        owner: root.hostWidget || root
        bar: root.bar
        open: root.opened
        focusTarget: keyCatcher

        contentWidth: panel.fittedContentWidth(Style.space(320))
        contentHeight: panel.fittedContentHeight(content.implicitHeight)

        PanelKeyCatcher {
            id: keyCatcher
            anchors.fill: parent
            onCloseRequested: root.close()

            ColumnLayout {
                id: content
                width: parent.width
                spacing: Style.space(12)

                Text {
                    text: "Créer un nouveau menu"
                    color: root.barForeground
                    font.bold: true
                    font.pixelSize: Style.font.subtitle
                }

                TextField {
                    id: menuNameInput
                    Layout.fillWidth: true
                    placeholderText: "Nom du menu (ex: Jeux, Dev...)"
                }

                Text {
                    text: "Sélectionne les applications :"
                    color: root.barForeground
                    font.pixelSize: Style.font.body
                }

                ListView {
                    id: appListView
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    clip: true
                    model: ListModel {
                        ListElement { appName: "Terminal"; selected: false }
                        ListElement { appName: "Navigateur"; selected: false }
                        ListElement { appName: "Discord"; selected: false }
                        ListElement { appName: "Geometry Dash"; selected: false }
                        ListElement { appName: "Editeur de texte"; selected: false }
                    }
                    delegate: RowLayout {
                        width: appListView.width
                        spacing: 8

                        CheckBox {
                            checked: model.selected
                            onCheckedChanged: model.selected = checked
                        }

                        Text {
                            text: model.appName
                            color: root.barForeground
                            Layout.fillWidth: true
                        }
                    }
                }

                Button {
                    Layout.alignment: Qt.AlignRight
                    text: "Sauvegarder"
                    onClicked: {
                        console.log("Menu créé : " + menuNameInput.text)
                        root.close()
                    }
                }
            }
        }
    }
}
