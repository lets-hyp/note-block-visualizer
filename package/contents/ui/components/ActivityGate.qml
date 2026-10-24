import QtQuick

// Decides whether the widget content should be shown.
// - becomes active immediately when sound shows up (and, if required, a player is playing)
// - becomes inactive only after `delaySeconds` without it, so short pauses don't blink
Item {
    id: root
    visible: false
    width: 0
    height: 0

    property var values: []
    property bool gateEnabled: true
    property bool requirePlayer: false
    property bool playerPlaying: false
    property int delaySeconds: 5

    readonly property bool active: _active

    property bool _active: true
    property bool _sound: false
    readonly property bool rawActive: _sound && (!requirePlayer || playerPlaying)

    onValuesChanged: {
        if (!gateEnabled) {
            return;
        }
        let sound = false;
        const v = values;
        if (v) {
            for (let i = 0; i < v.length; i++) {
                if (v[i] > 0) {
                    sound = true;
                    break;
                }
            }
        }
        if (sound !== _sound) {
            _sound = sound;
        }
    }

    onRawActiveChanged: update()
    onGateEnabledChanged: update()

    function update() {
        if (!gateEnabled) {
            hideTimer.stop();
            _active = true;
            return;
        }
        if (rawActive) {
            hideTimer.stop();
            _active = true;
        } else if (_active && !hideTimer.running) {
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: Math.max(1, root.delaySeconds) * 1000
        onTriggered: root._active = false
    }

    Component.onCompleted: update()
}
