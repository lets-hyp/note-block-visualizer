import QtQuick

// Square slot that shows the cover image (PNG/JPG/GIF) next to the visualizer.
Item {
    id: root

    // empty = bundled note block; otherwise a local path or a URL
    property string source: ""
    readonly property bool usingDefault: source === ""
    readonly property url resolvedSource: {
        if (usingDefault) {
            return Qt.resolvedUrl("../images/noteblock.png");
        }
        if (source.startsWith("/")) {
            return "file://" + source;
        }
        return source;
    }

    AnimatedImage {
        id: image
        anchors.fill: parent
        source: root.resolvedSource
        fillMode: Image.PreserveAspectFit
        // keep the bundled pixel art crisp, smooth everything else
        smooth: !root.usingDefault
        playing: root.visible
    }
}
