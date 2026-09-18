import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
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
    function toggle() { 
        if (root.controller.visible) root.close(); 
        else root.open(); 
    }

    // Raccourci global Super + Z pour ouvrir/fermer le menu
    GlobalShortcut {
        name: "app-menu-toggle"
        text: "Super+Z"
        onPressed: root.toggle()
    }

    // Processus pour lister les applications du PC (.desktop)
    Process {
        id: appListerProcess
        command: ["sh", "-c", "grep -h '^Name=' /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop 2>/dev/null | cut -d= -f2 | sort -u"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                if (data.trim().length > 0) {
                    allAppsModel.append({ appName: data.trim(), selected: false })
                }
            }
        }
    }

    // Processus pour sauvegarder le menu sur le disque
    Process {
        id: saveProcess
        running: false
    }

    Component.onCompleted: {
        appListerProcess.running = true
    }

    KeyboardPanel {
        id: panel
        anchorItem: root.anchorItem
        owner: root.hostWidget || root
        bar: root.bar
        open: root.opened
        focusTarget: keyCatcher

        contentWidth: panel.fittedContentWidth(Style.space(360))
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

                // Champ de saisie du nom du menu
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

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    CheckBox {
                        id: browserAppsToggle
                        checked: true
                    }

                    Text {
                        text: "Lister toutes les applications du PC"
                        color: root.barForeground
                        font.pixelSize: Style.font.body
                    }
                }

                // Liste dynamique de toutes les applications de l'ordinateur
                ListView {
                    id: appListView
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    clip: true
                    visible: browserAppsToggle.checked
                    model: ListModel { id: allAppsModel }
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
                            elide: Text.ElideRight
                        }
                    }
                }

                Button {
                    Layout.alignment: Qt.AlignRight
                    text: "Sauvegarder"
                    onClicked: {
                        var menuName = menuNameInput.text.trim();
                        if (menuName.length === 0) return;

                        // Récupération des apps cochées
                        var selectedApps = [];
                        for (var i = 0; i < allAppsModel.count; i++) {
                            if (allAppsModel.get(i).selected) {
                                selectedApps.push(allAppsModel.get(i).appName);
                            }
                        }

                        // Sauvegarde dans un fichier JSON local via un script bash
                        var payload = JSON.stringify({ name: menuName, apps: selectedApps });
                        saveProcess.command = ["sh", "-c", "mkdir -p ~/.config/omarchy/app-menus && echo '" + payload + "' > ~/.config/omarchy/app-menus/" + menuName + ".json"];
                        saveProcess.running = true;

                        console.log("Menu '" + menuName + "' sauvegardé avec " + selectedApps.length + " applications.");
                        root.close();
                    }
                }
            }
        }
    }
}
