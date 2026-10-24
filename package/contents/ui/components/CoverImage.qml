import QtQuick

// Square slot that shows the cover image (PNG/JPG/GIF) next to the visualizer.
// Can bounce with the music: the image rests slightly smaller and grows to the full slot.
Item {
    id: root

    // empty = bundled note block; otherwise a local path or a URL
    property string source: ""

    // 0 = off, 1 = pulse on beat (call pulse()), 2 = follow bass level
    property int bounceMode: 0
    property real bounceStrength: 0.12
    property real level: 0

    // animated images (GIF) only advance while this is true
    property bool animated: true

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

    readonly property real restScale: bounceMode === 0 ? 1.0 : 1.0 / (1.0 + bounceStrength)
    property real pulseFactor: 1.0
    readonly property real followFactor: 1.0 + bounceStrength * Math.min(1.0, level * 1.5)

    function pulse() {
        if (bounceMode === 1) {
            pulseAnim.restart();
        }
    }

    onBounceModeChanged: pulseFactor = 1.0

    AnimatedImage {
        id: image
        anchors.fill: parent
        transformOrigin: Item.Center
        source: root.resolvedSource
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        // keep the bundled pixel art crisp, smooth everything else
        smooth: !root.usingDefault
        // pause (not stop) so a GIF resumes from the frame it was paused on
        playing: true
        paused: !(root.visible && root.animated)
        scale: root.restScale * (root.bounceMode === 2 ? root.followFactor : root.pulseFactor)
        Behavior on scale {
            enabled: root.bounceMode === 2
            NumberAnimation {
                duration: 70
            }
        }
    }

    SequentialAnimation {
        id: pulseAnim
        NumberAnimation {
            target: root
            property: "pulseFactor"
            to: 1.0 + root.bounceStrength
            duration: 60
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "pulseFactor"
            to: 1.0
            duration: 240
            easing.type: Easing.OutBack
        }
    }
}
