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

        contentWidth: panel.fittedContentWidth(Style.space(340))
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

                // Rectangle bien visible pour le nom du menu
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    color: "transparent"
                    border.color: root.barForeground
                    border.width: 1
                    radius: 4

                    TextInput {
                        id: menuNameInput
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        verticalAlignment: TextInput.AlignVCenter
                        color: root.barForeground
                        font.pixelSize: Style.font.body

                        Text {
                            text: "Nom du menu (ex: Jeux, Dev...)"
                            color: root.barForeground
                            opacity: 0.4
                            visible: menuNameInput.text.length === 0
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Text {
                    text: "Sélectionne les applications :"
                    color: root.barForeground
                    font.pixelSize: Style.font.body
                }

                ListView {
                    id: appListView
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    clip: true
                    model: ListModel {
                        ListElement { appName: "Terminal"; selected: false }
                        ListElement { appName: "Navigateur Web (Firefox / Chrome)"; selected: false }
                        ListElement { appName: "Discord"; selected: false }
                        ListElement { appName: "Geometry Dash"; selected: false }
                        ListElement { appName: "Éditeur de texte"; selected: false }
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
                            font.pixelSize: Style.font.body
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
