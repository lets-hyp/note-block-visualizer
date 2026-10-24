import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: root

    property bool cfg_fadeEnabled
    property int cfg_fadeDelay
    property int cfg_fadeDuration

    property bool cfg_fadeEnabledDefault
    property int cfg_fadeDelayDefault
    property int cfg_fadeDurationDefault

    Kirigami.FormLayout {
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Fade out when silent")
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Hide:")
            text: i18n("Fade out the visualizer and image when there is no sound")
            checked: root.cfg_fadeEnabled
            onToggled: root.cfg_fadeEnabled = checked
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Wait for:")
            enabled: root.cfg_fadeEnabled
            from: 1
            to: 120
            value: root.cfg_fadeDelay
            onValueModified: root.cfg_fadeDelay = value
            textFromValue: (value, locale) => i18n("%1 s", value)
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Fade time:")
            enabled: root.cfg_fadeEnabled
            from: 0
            to: 3000
            stepSize: 100
            value: root.cfg_fadeDuration
            onValueModified: root.cfg_fadeDuration = value
            textFromValue: (value, locale) => value === 0 ? i18n("Instant") : i18n("%1 ms", value)
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("Everything comes back with a fade-in as soon as sound is detected. If specific players are selected in the Now playing page, their playback state counts too, not just the sound. The widget background is drawn by Plasma and stays visible.")
        }
    }
}
