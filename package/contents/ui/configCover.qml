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

    // filled in by the config system, declared to avoid warnings
    property bool cfg_showImageDefault
    property int cfg_imagePositionDefault
    property string cfg_imageSourceDefault
    property int cfg_imageSpacingDefault

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: showImageCheck
            Kirigami.FormData.label: i18n("Cover image:")
            text: i18n("Show image next to the visualizer")
            checked: root.cfg_showImage
            onToggled: root.cfg_showImage = checked
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("Only shown for the Top and Bottom visualizer orientations, not in circle mode.")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Position:")
            enabled: root.cfg_showImage
            model: [i18n("Left"), i18n("Right")]
            currentIndex: root.cfg_imagePosition
            onActivated: root.cfg_imagePosition = currentIndex
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Spacing:")
            enabled: root.cfg_showImage
            from: 0
            to: 64
            value: root.cfg_imageSpacing
            onValueModified: root.cfg_imageSpacing = value
            textFromValue: (value, locale) => i18n("%1 px", value)
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Image file:")
            enabled: root.cfg_showImage

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
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("PNG, JPG and GIF files work. GIFs are animated.")
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
