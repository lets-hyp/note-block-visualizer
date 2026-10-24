import QtQuick
import org.kde.kirigami as Kirigami

// Pixel-font text with a drop shadow. Scrolls back and forth when it is wider than the item.
Item {
    id: root

    property string text: ""
    property color color: "#ff6a1a"
    property int pixelSize: 16
    property bool alignRight: false
    property bool shown: true

    property real scrollX: 0
    readonly property bool overflow: root.width > 0 && label.implicitWidth > root.width
    readonly property int shadowOffset: Math.max(1, Math.round(pixelSize / 8))
    readonly property real restX: (alignRight && !overflow) ? root.width - label.implicitWidth - shadowOffset : 0
    readonly property string fontFamily: pixelFont.status === FontLoader.Ready ? pixelFont.name : Kirigami.Theme.defaultFont.family

    implicitHeight: label.implicitHeight + shadowOffset
    clip: true
    opacity: shown ? 1 : 0
    visible: opacity > 0.01
    Behavior on opacity {
        NumberAnimation {
            duration: 250
        }
    }

    onTextChanged: {
        scrollX = 0;
        if (scroll.running) {
            scroll.restart();
        }
    }
    onOverflowChanged: {
        if (!overflow) {
            scrollX = 0;
        }
    }

    FontLoader {
        id: pixelFont
        source: Qt.resolvedUrl("../fonts/Monocraft.ttf")
    }

    Text {
        id: shadow
        x: label.x + root.shadowOffset
        y: root.shadowOffset
        text: root.text
        color: Qt.darker(root.color, 4)
        textFormat: Text.PlainText
        renderType: Text.NativeRendering
        font.family: root.fontFamily
        font.pixelSize: root.pixelSize
    }

    Text {
        id: label
        x: root.restX + root.scrollX
        text: root.text
        color: root.color
        textFormat: Text.PlainText
        renderType: Text.NativeRendering
        font.family: root.fontFamily
        font.pixelSize: root.pixelSize
    }

    SequentialAnimation {
        id: scroll
        loops: Animation.Infinite
        running: root.overflow && root.visible
        PauseAnimation {
            duration: 1500
        }
        NumberAnimation {
            target: root
            property: "scrollX"
            from: 0
            to: -(label.implicitWidth - root.width + root.shadowOffset)
            duration: Math.max(1, (label.implicitWidth - root.width) * 30)
            easing.type: Easing.Linear
        }
        PauseAnimation {
            duration: 1500
        }
        NumberAnimation {
            target: root
            property: "scrollX"
            to: 0
            duration: 300
            easing.type: Easing.OutQuad
        }
    }
}
