import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: root

    property bool cfg_trackTextEnabled
    property int cfg_trackTextPosition
    property int cfg_trackTextSize
    property color cfg_trackTextColor
    property bool cfg_trackTextShowArtist
    property bool cfg_trackTextOnlyWhenPlaying
    property bool cfg_playersAllowAll
    property var cfg_allowedPlayers: []

    property bool cfg_trackTextEnabledDefault
    property int cfg_trackTextPositionDefault
    property int cfg_trackTextSizeDefault
    property color cfg_trackTextColorDefault
    property bool cfg_trackTextShowArtistDefault
    property bool cfg_trackTextOnlyWhenPlayingDefault
    property bool cfg_playersAllowAllDefault
    property var cfg_allowedPlayersDefault: []

    readonly property bool textOn: cfg_trackTextEnabled

    // players found right now + the ones already saved (so a closed app stays in the list)
    readonly property var knownPlayers: {
        const names = [];
        for (const n of detector.playerList) {
            if (names.indexOf(n) < 0) {
                names.push(n);
            }
        }
        for (const n of Array.from(root.cfg_allowedPlayers)) {
            if (names.indexOf(n) < 0) {
                names.push(n);
            }
        }
        return names;
    }

    // only used to discover which players exist
    NowPlaying {
        id: detector
    }

    Kirigami.FormLayout {
        // -------------------------------------------------------------- Display
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Track name")
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Show:")
            text: i18n("Show the name of the playing track")
            checked: root.cfg_trackTextEnabled
            onToggled: root.cfg_trackTextEnabled = checked
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Position:")
            enabled: root.textOn
            model: [i18n("Auto (opposite side of the bars)"), i18n("Above the bars"), i18n("Below the bars")]
            currentIndex: root.cfg_trackTextPosition
            onActivated: root.cfg_trackTextPosition = currentIndex
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Content:")
            enabled: root.textOn
            text: i18n("Include the artist")
            checked: root.cfg_trackTextShowArtist
            onToggled: root.cfg_trackTextShowArtist = checked
        }

        QQC2.CheckBox {
            enabled: root.textOn
            text: i18n("Only while playing")
            checked: root.cfg_trackTextOnlyWhenPlaying
            onToggled: root.cfg_trackTextOnlyWhenPlaying = checked
        }

        // ----------------------------------------------------------- Appearance
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Appearance")
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Size:")
            enabled: root.textOn
            from: 8
            to: 64
            value: root.cfg_trackTextSize
            onValueModified: root.cfg_trackTextSize = value
            textFromValue: (value, locale) => i18n("%1 px", value)
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Color:")
            enabled: root.textOn
            Rectangle {
                implicitWidth: Kirigami.Units.gridUnit * 2
                implicitHeight: Kirigami.Units.gridUnit * 1.5
                radius: 3
                color: root.cfg_trackTextColor
                border.width: 1
                border.color: Kirigami.Theme.textColor
            }
            QQC2.Button {
                text: i18n("Choose…")
                icon.name: "color-management"
                onClicked: colorDialog.open()
            }
        }

        // -------------------------------------------------------------- Players
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Players")
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Use:")
            text: i18n("All media players")
            checked: root.cfg_playersAllowAll
            onToggled: root.cfg_playersAllowAll = checked
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Only these:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop
            visible: !root.cfg_playersAllowAll

            Repeater {
                model: root.knownPlayers
                delegate: QQC2.CheckBox {
                    required property string modelData
                    text: modelData
                    checked: Array.from(root.cfg_allowedPlayers).indexOf(modelData) !== -1
                    onToggled: {
                        const list = Array.from(root.cfg_allowedPlayers);
                        const i = list.indexOf(modelData);
                        if (checked && i < 0) {
                            list.push(modelData);
                        } else if (!checked && i >= 0) {
                            list.splice(i, 1);
                        }
                        root.cfg_allowedPlayers = list;
                    }
                }
            }

            QQC2.Label {
                Layout.maximumWidth: Kirigami.Units.gridUnit * 22
                wrapMode: Text.WordWrap
                opacity: 0.7
                text: root.knownPlayers.length === 0 ? i18n("No media players found. Start a player and it will show up here.") : i18n("Apps that are not running only show up here after you tick them once while they are open.")
            }
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("The player filter applies to the track name, the album art and the GIF animation. The track name is only shown for the Top and Bottom visualizer orientations, not in circle mode.")
        }
    }

    ColorDialog {
        id: colorDialog
        title: i18n("Choose a text color")
        selectedColor: root.cfg_trackTextColor
        onAccepted: root.cfg_trackTextColor = selectedColor
    }
}
