import QtQuick
import org.kde.plasma.private.mpris as Mpris

// Currently playing track, read from MPRIS (Spotify, browsers, ...).
//
// Mpris2Model lists every MPRIS player and exposes one of them as `currentPlayer`
// (the one at `currentIndex`). To follow the player that is actually playing, we
// walk the players, copy the data of the best one into our own properties and
// leave `currentIndex` on it. Our properties only change when the data changes,
// so the text doesn't flicker while we look around.
Item {
    id: root
    visible: false
    width: 0
    height: 0

    property string title: ""
    property string artist: ""
    property string artUrl: ""
    property bool playing: false

    // which players to follow: everything, or only the listed identities (e.g. "Spotify")
    property bool allowAll: true
    property var allowed: []
    // identities of every player currently found (used by the settings page)
    property var playerList: []
    // true while a window covers the widget: no polling needed
    property bool paused: false

    property int _lastCount: -1
    property bool _warnedUndefined: false

    function isAllowed(identity) {
        if (allowAll) {
            return true;
        }
        const list = allowed ? Array.from(allowed) : [];
        return list.indexOf(identity) !== -1;
    }

    function refresh() {
        const n = players.count;
        if (n !== _lastCount) {
            _lastCount = n;
        }
        if (n === 0) {
            if (playerList.length > 0) {
                playerList = [];
            }
            apply("", "", "", false);
            return;
        }

        const original = playersModel.currentIndex;
        let best = null;
        const names = [];
        for (let i = 0; i < n; i++) {
            playersModel.currentIndex = i;
            const p = playersModel.currentPlayer;
            if (!p) {
                if (!_warnedUndefined) {
                    _warnedUndefined = true;
                    console.log("[NowPlaying] currentPlayer is undefined for index", i);
                }
                continue;
            }
            const identity = p.identity ? String(p.identity) : "";
            if (identity !== "") {
                names.push(identity);
            }
            if (!isAllowed(identity)) {
                continue;
            }
            const cand = {
                index: i,
                title: p.track ? String(p.track) : "",
                artist: p.artist ? String(p.artist) : "",
                artUrl: p.artUrl ? p.artUrl.toString() : "",
                playing: p.playbackStatus === Mpris.PlaybackStatus.Playing
            };
            if (cand.playing) {
                best = cand;
                break;
            }
            // nothing is playing: fall back to the first player that has a track
            if (best === null && cand.title !== "") {
                best = cand;
            }
        }

        if (JSON.stringify(names) !== JSON.stringify(playerList)) {
            playerList = names;
        }
        playersModel.currentIndex = best ? best.index : original;
        if (best) {
            apply(best.title, best.artist, best.artUrl, best.playing);
        } else {
            apply("", "", "", false);
        }
    }

    function apply(newTitle, newArtist, newArtUrl, newPlaying) {
        title = newTitle;
        artist = newArtist;
        artUrl = newArtUrl;
        playing = newPlaying;
    }

    Mpris.Mpris2Model {
        id: playersModel
    }

    Repeater {
        id: players
        model: playersModel
        delegate: Item {}
        onCountChanged: root.refresh()
    }

    Timer {
        interval: 700
        running: !root.paused
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
