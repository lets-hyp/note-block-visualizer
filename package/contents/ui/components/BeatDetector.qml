import QtQuick

// Simple bass-energy beat detector fed with CAVA bar values.
// - `beat` fires when the low bars jump well above their recent average
// - `level` is the current normalized bass energy (0..1)
Item {
    id: root
    visible: false
    width: 0
    height: 0

    property var values: []
    property real maxRange: 100
    property bool stereo: false
    property bool reverse: false
    property real sensitivity: 50 // 1..100, higher triggers more easily
    property bool active: true

    property real level: 0
    signal beat

    property real _avg: 0
    property real _prev: 0
    property double _lastBeat: 0

    onValuesChanged: {
        if (!active || !values || values.length === 0 || maxRange <= 0) {
            return;
        }
        const n = values.length;
        const halves = stereo ? 2 : 1;
        const half = Math.floor(n / halves);
        if (half < 1) {
            return;
        }
        // lowest ~15% of the bars of each channel
        const k = Math.max(1, Math.round(half * 0.15));
        let sum = 0;
        for (let h = 0; h < halves; h++) {
            const base = h * half;
            for (let i = 0; i < k; i++) {
                const idx = reverse ? base + half - 1 - i : base + i;
                sum += values[idx];
            }
        }
        const raw = Math.min(1, sum / (k * halves) / maxRange);
        level = raw;

        const ratio = 1.8 - 0.65 * (Math.max(1, Math.min(100, sensitivity)) / 100);
        const now = Date.now();
        if (raw > _avg * ratio + 0.03 && raw > _prev && now - _lastBeat > 140) {
            _lastBeat = now;
            beat();
        }
        _avg += (raw - _avg) * 0.04;
        _prev = raw;
    }
}
