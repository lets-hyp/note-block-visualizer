import QtCore
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: root

    property bool cfg_showImage
    property int cfg_imagePosition
    property string cfg_imageSource
    property int cfg_imageSpacing
    property int cfg_imageSize
    property int cfg_imageOpacity
    property bool cfg_imageUseAlbumArt
    property bool cfg_gifOnlyWhenPlaying
    property int cfg_bounceMode
    property int cfg_bounceStrength
    property int cfg_bounceSensitivity

    // filled in by the config system, declared to avoid warnings
    property bool cfg_showImageDefault
    property int cfg_imagePositionDefault
    property string cfg_imageSourceDefault
    property int cfg_imageSpacingDefault
    property int cfg_imageSizeDefault
    property int cfg_imageOpacityDefault
    property bool cfg_imageUseAlbumArtDefault
    property bool cfg_gifOnlyWhenPlayingDefault
    property int cfg_bounceModeDefault
    property int cfg_bounceStrengthDefault
    property int cfg_bounceSensitivityDefault

    readonly property bool imageOn: cfg_showImage

    Kirigami.FormLayout {
        // ---------------------------------------------------------------- Image
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Image")
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Show:")
            text: i18n("Show an image next to or over the visualizer")
            checked: root.cfg_showImage
            onToggled: root.cfg_showImage = checked
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Position:")
            enabled: root.imageOn
            model: [i18n("Left"), i18n("Right"), i18n("Center (over the visualizer)")]
            currentIndex: root.cfg_imagePosition
            onActivated: root.cfg_imagePosition = currentIndex
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Size:")
            enabled: root.imageOn
            from: 10
            to: 100
            stepSize: 5
            value: root.cfg_imageSize
            onValueModified: root.cfg_imageSize = value
            textFromValue: (value, locale) => i18n("%1 %", value)
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Opacity:")
            enabled: root.imageOn
            from: 10
            to: 100
            stepSize: 5
            value: root.cfg_imageOpacity
            onValueModified: root.cfg_imageOpacity = value
            textFromValue: (value, locale) => i18n("%1 %", value)
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Spacing:")
            enabled: root.imageOn && root.cfg_imagePosition !== 2
            from: 0
            to: 64
            value: root.cfg_imageSpacing
            onValueModified: root.cfg_imageSpacing = value
            textFromValue: (value, locale) => i18n("%1 px", value)
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Source")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Image file:")
            enabled: root.imageOn

            QQC2.TextField {
                Layout.preferredWidth: Kirigami.Units.gridUnit * 14
                placeholderText: i18n("Default (note block)")
                text: root.cfg_imageSource
                onTextEdited: root.cfg_imageSource = text
            }
            QQC2.Button {
                icon.name: "document-open-symbolic"
                text: i18n("Browse…")
                onClicked: fileDialog.open()
            }
            QQC2.Button {
                icon.name: "edit-clear-symbolic"
                text: i18n("Reset")
                enabled: root.cfg_imageSource !== ""
                onClicked: root.cfg_imageSource = ""
            }
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("PNG, JPG and GIF files work.")
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Album art:")
            enabled: root.imageOn
            text: i18n("Use the album art of the playing track")
            checked: root.cfg_imageUseAlbumArt
            onToggled: root.cfg_imageUseAlbumArt = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("GIF:")
            enabled: root.imageOn
            text: i18n("Animate only while music is playing")
            checked: root.cfg_gifOnlyWhenPlaying
            onToggled: root.cfg_gifOnlyWhenPlaying = checked
        }

        // ------------------------------------------------------------ Animation
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Beat bounce")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Mode:")
            enabled: root.imageOn
            model: [i18n("Off"), i18n("Pulse on beat"), i18n("Follow bass")]
            currentIndex: root.cfg_bounceMode
            onActivated: root.cfg_bounceMode = currentIndex
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Strength:")
            enabled: root.imageOn && root.cfg_bounceMode !== 0
            from: 1
            to: 40
            value: root.cfg_bounceStrength
            onValueModified: root.cfg_bounceStrength = value
            textFromValue: (value, locale) => i18n("%1 %", value)
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Sensitivity:")
            enabled: root.imageOn && root.cfg_bounceMode === 1
            from: 1
            to: 100
            value: root.cfg_bounceSensitivity
            onValueModified: root.cfg_bounceSensitivity = value
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("Higher sensitivity triggers the pulse more easily. The image rests slightly smaller and grows to its full size on the beat.")
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("The image is only shown for the Top and Bottom visualizer orientations, not in circle mode.")
        }
    }

    FileDialog {
        id: fileDialog
        title: i18n("Choose an image")
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: [i18n("Images (*.png *.jpg *.jpeg *.gif *.webp *.bmp)"), i18n("All files (*)")]
        onAccepted: root.cfg_imageSource = selectedFile.toString()
    }
}
