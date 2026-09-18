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
    property bool isEditing: false

    function open() { root.controller.show() }
    function close() { 
        searchInput.text = "";
        root.isEditing = false;
        root.controller.hide(); 
    }

    ListModel { id: savedAppsModel }
    ListModel { id: allAppsModel }

    Process {
        id: loadSavedApps
        command: ["sh", "-c", "cat ~/.config/omarchy/app-menus/current.json 2>/dev/null"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    var json = JSON.parse(data.trim());
                    savedAppsModel.clear();
                    if (json.apps) {
                        var seenNames = {};
                        for (var i = 0; i < json.apps.length; i++) {
                            var appName = json.apps[i].name;
                            if (!seenNames[appName]) {
                                seenNames[appName] = true;
                                savedAppsModel.append({ appName: appName, appExec: json.apps[i].exec });
                            }
                        }
                    }
                } catch(e) {}
            }
        }
    }

    Process {
        id: loadAllApps
        command: ["python3", "-c", "
import glob, configparser, os, json
saved_names = set()
config_path = os.path.expanduser('~/.config/omarchy/app-menus/current.json')
if os.path.exists(config_path):
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            if 'apps' in data:
                saved_names = {app['name'] for app in data['apps']}
    except: pass

apps = []
seen = set()
paths = ['/usr/share/applications/*.desktop', os.path.expanduser('~/.local/share/applications/*.desktop')]
for p in paths:
    for f in glob.glob(p):
        config = configparser.ConfigParser(interpolation=None)
        try:
            config.read(f, encoding='utf-8')
            if 'Desktop Entry' in config:
                de = config['Desktop Entry']
                if de.get('Type') == 'Application' and not de.get('NoDisplay') == 'true':
                    name = de.get('Name', '')
                    exec_cmd = de.get('Exec', '')
                    if name and exec_cmd and name not in seen:
                        seen.add(name)
                        apps.append({'name': name, 'exec': exec_cmd, 'selected': name in saved_names})
        except: pass
print(json.dumps(apps))
"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                try {
                    var list = JSON.parse(data.trim());
                    allAppsModel.clear();
                    for (var i = 0; i < list.length; i++) {
                        allAppsModel.append({ appName: list[i].name, appExec: list[i].exec, selected: list[i].selected });
                    }
                } catch(e) {}
            }
        }
    }

    Process { id: actionProcess; running: false }

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
                spacing: Style.space(10)

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: root.isEditing ? "Configuration du Menu" : (hostWidget ? hostWidget.menuName : "Mon Menu")
                        color: root.barForeground
                        font.bold: true
                        font.pixelSize: Style.font.subtitle
                        Layout.fillWidth: true
                    }
                    Button {
                        text: root.isEditing ? "◀ Retour" : "⚙ Config / Add"
                        onClicked: {
                            root.isEditing = !root.isEditing;
                            if (root.isEditing) {
                                loadAllApps.running = true;
                            } else {
                                searchInput.text = "";
                            }
                        }
                    }
                }

                // --- VUE NORMALE (Apps sauvegardées avec bouton de suppression) ---
                ListView {
                    id: savedListView
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    clip: true
                    visible: !root.isEditing
                    model: savedAppsModel
                    delegate: Rectangle {
                        width: savedListView.width
                        height: 38
                        color: "transparent"
                        RowLayout {
                            anchors.fill: parent
                            spacing: 10
                            
                            MouseArea {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onMouseXChanged: {}
                                onClicked: {
                                    var cleanExec = model.appExec.replace(/%[a-zA-Z]/g, "").trim();
                                    actionProcess.command = ["sh", "-c", "nohup " + cleanExec + " >/dev/null 2>&1 &"];
                                    actionProcess.running = true;
                                    root.close();
                                }
                                Text {
                                    text: "🔹 " + model.appName
                                    color: root.barForeground
                                    font.pixelSize: Style.font.body
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Button {
                                text: "🗑️"
                                implicitWidth: 32
                                implicitHeight: 32
                                onClicked: {
                                    // Supprimer l'application de la liste et mettre à jour le fichier JSON
                                    savedAppsModel.remove(index);
                                    var updatedApps = [];
                                    for (var i = 0; i < savedAppsModel.count; i++) {
                                        updatedApps.push({ name: savedAppsModel.get(i).appName, exec: savedAppsModel.get(i).appExec });
                                    }
                                    var menuName = hostWidget ? hostWidget.menuName : "Mon Menu";
                                    var payload = JSON.stringify({ name: menuName, apps: updatedApps });
                                    actionProcess.command = ["sh", "-c", "mkdir -p ~/.config/omarchy/app-menus && echo '" + payload.replace(/'/g, "'\\''") + "' > ~/.config/omarchy/app-menus/current.json"];
                                    actionProcess.running = true;
                                }
                            }
                        }
                    }
                }

                // --- VUE CONFIGURATION / AJOUT ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.isEditing

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        color: "transparent"
                        border.color: root.barForeground
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: menuNameInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.barForeground
                            font.pixelSize: Style.font.body
                            text: hostWidget && hostWidget.menuName !== "+ Add the app" ? hostWidget.menuName : ""

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

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: "transparent"
                        border.color: root.barForeground
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.barForeground
                            font.pixelSize: Style.font.body

                            Text {
                                text: "🔍 Rechercher une application..."
                                color: root.barForeground
                                opacity: 0.4
                                visible: searchInput.text.length === 0
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    ListView {
                        id: configListView
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        clip: true
                        model: allAppsModel
                        delegate: Rectangle {
                            width: configListView.width
                            height: matchQuery ? 32 : 0
                            visible: matchQuery
                            color: "transparent"

                            property bool matchQuery: searchInput.text.length === 0 || model.appName.toLowerCase().includes(searchInput.text.toLowerCase())

                            RowLayout {
                                anchors.fill: parent
                                spacing: 6
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
                    }

                    Button {
                        Layout.alignment: Qt.AlignRight
                        text: "Enregistrer"
                        onClicked: {
                            var menuName = menuNameInput.text.trim();
                            if (menuName.length === 0) return;

                            var selectedApps = [];
                            var uniqueCheck = {};
                            for (var i = 0; i < allAppsModel.count; i++) {
                                var item = allAppsModel.get(i);
                                if (item && item.selected && !uniqueCheck[item.appName]) {
                                    uniqueCheck[item.appName] = true;
                                    selectedApps.push({ name: item.appName, exec: item.appExec });
                                }
                            }

                            var payload = JSON.stringify({ name: menuName, apps: selectedApps });
                            actionProcess.command = ["sh", "-c", "mkdir -p ~/.config/omarchy/app-menus && echo '" + payload.replace(/'/g, "'\\''") + "' > ~/.config/omarchy/app-menus/current.json"];
                            actionProcess.running = true;

                            if (hostWidget) hostWidget.menuName = menuName;
                            root.isEditing = false;
                            searchInput.text = "";
                            loadSavedApps.running = true;
                            root.close();
                        }
                    }
                }
            }
        }
    }
}
