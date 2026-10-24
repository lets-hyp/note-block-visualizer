import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "./components"
import "code/enum.js" as Enum
import "code/globals.js" as Globals
import "code/utils.js" as Utils

Item {
    id: root

    Layout.preferredWidth: Plasmoid.configuration.expanding || main.onDesktop ? -1 : content.implicitWidth
    Layout.preferredHeight: Plasmoid.configuration.expanding || main.onDesktop ? -1 : content.implicitHeight
    Layout.minimumWidth: Plasmoid.configuration.expanding ? (main.horizontal ? Plasmoid.configuration.minimumLength : -1) : Layout.preferredWidth
    Layout.minimumHeight: Plasmoid.configuration.expanding ? (!main.horizontal ? Plasmoid.configuration.minimumLength : -1) : Layout.preferredHeight
    Layout.fillHeight: main.horizontal || Plasmoid.configuration.expanding || main.onDesktop
    Layout.fillWidth: !main.horizontal || Plasmoid.configuration.expanding || main.onDesktop

    property int framerate: Plasmoid.configuration.framerate
    property int barGap: Plasmoid.configuration.barGap
    property int barWidth: Plasmoid.configuration.barWidth
    property int blockHeight: Plasmoid.configuration.blockHeight
    property int blockSpacing: Plasmoid.configuration.blockSpacing
    property int noiseReduction: Plasmoid.configuration.noiseReduction
    property int monstercat: Plasmoid.configuration.monstercat
    property int waves: Plasmoid.configuration.waves
    property bool centeredBars: Plasmoid.configuration.centeredBars
    property int waveMode: Plasmoid.configuration.waveMode
    property bool roundedBars: Plasmoid.configuration.roundedBars
    property int visualizerStyle: Plasmoid.configuration.visualizerStyle
    property bool circleMode: Plasmoid.configuration.circleMode
    property real circleModeSize: Plasmoid.configuration.circleModeSize
    property bool fillWave: Plasmoid.configuration.fillWave
    property int orientation: Plasmoid.configuration.orientation
    property bool disableLeftClick: Plasmoid.configuration.disableLeftClick
    property bool stereo: Plasmoid.configuration.outputChannels === "stereo"
    property bool waveSimulateWaveform: Plasmoid.configuration.waveSimulateWaveform
    property bool circleModeFill: Plasmoid.configuration.circleModeFill
    property bool pinnedDownSides: Plasmoid.configuration.pinnedDownSides
    property bool waveform: Plasmoid.configuration.waveform
    property bool showImage: Plasmoid.configuration.showImage
    property int imagePosition: Plasmoid.configuration.imagePosition
    property string imageSource: Plasmoid.configuration.imageSource
    property int imageSpacing: Plasmoid.configuration.imageSpacing
    property bool useAlbumArt: Plasmoid.configuration.imageUseAlbumArt
    property int imageSize: Plasmoid.configuration.imageSize
    property int imageOpacity: Plasmoid.configuration.imageOpacity
    property bool gifOnlyWhenPlaying: Plasmoid.configuration.gifOnlyWhenPlaying
    property bool fadeEnabled: Plasmoid.configuration.fadeEnabled
    property int fadeDelay: Plasmoid.configuration.fadeDelay
    property int fadeDuration: Plasmoid.configuration.fadeDuration
    // with specific players selected, the visualizer follows them
    property bool followPlayers: Plasmoid.configuration.requirePlayerPlaying && !Plasmoid.configuration.playersAllowAll
    // 1 = fully shown, 0 = faded out (animated)
    property real fadeLevel: (activityGate.active || cava.hasError) ? 1.0 : 0.0
    Behavior on fadeLevel {
        NumberAnimation {
            duration: root.fadeDuration
            easing.type: Easing.InOutQuad
        }
    }
    readonly property bool imageSideLayout: imageAllowed && imagePosition !== Enum.ImagePosition.Center
    property int bounceMode: Plasmoid.configuration.bounceMode
    property real bounceStrength: Plasmoid.configuration.bounceStrength / 100
    readonly property string coverSource: (useAlbumArt && nowPlaying.artUrl !== "") ? nowPlaying.artUrl : imageSource

    property bool trackTextEnabled: Plasmoid.configuration.trackTextEnabled
    property int trackTextPosition: Plasmoid.configuration.trackTextPosition
    property int trackTextSize: Plasmoid.configuration.trackTextSize
    property color trackTextColor: Plasmoid.configuration.trackTextColor
    property bool trackTextShowArtist: Plasmoid.configuration.trackTextShowArtist
    property bool trackTextOnlyWhenPlaying: Plasmoid.configuration.trackTextOnlyWhenPlaying
    readonly property string trackTextValue: {
        const title = nowPlaying.title;
        if (title === "") {
            return "";
        }
        return (trackTextShowArtist && nowPlaying.artist !== "") ? nowPlaying.artist + " - " + title : title;
    }
    readonly property bool trackTextActive: trackTextEnabled && !circleMode && [Enum.Orientation.Top, Enum.Orientation.Bottom].includes(orientation) && trackTextValue !== "" && (!trackTextOnlyWhenPlaying || nowPlaying.playing)
    // Auto = opposite side of where the bars grow from
    readonly property bool trackTextOnTop: trackTextPosition === Enum.TextPosition.Auto ? orientation === Enum.Orientation.Bottom : trackTextPosition === Enum.TextPosition.Top
    readonly property bool trackTextAlignRight: imageAllowed && imagePosition === Enum.ImagePosition.Right
    // the image only makes sense for the normal bottom/top bar layouts
    readonly property bool imageAllowed: showImage && !circleMode && [Enum.Orientation.Top, Enum.Orientation.Bottom].includes(orientation)
    clip: !Plasmoid.configuration.debugMode

    property var logger: Logger.create(Plasmoid.configuration.debugMode ? LoggingCategory.Debug : LoggingCategory.Info)

    property var barColorsCfg: {
        let barColors;
        try {
            barColors = JSON.parse(Plasmoid.configuration.barColors);
        } catch (e) {
            logger.error(e, e.stack);
            globalSettings = Globals.baseBarColors;
        }
        const config = Utils.mergeConfigs(Globals.baseBarColors, barColors);
        const configStr = JSON.stringify(config);
        if (Plasmoid.configuration.barColors !== configStr) {
            Plasmoid.configuration.barColors = configStr;
            Plasmoid.configuration.writeConfig();
        }
        return config;
    }

    property var waveFillColorsCfg: {
        let waveFillColors;
        try {
            waveFillColors = JSON.parse(Plasmoid.configuration.waveFillColors);
        } catch (e) {
            logger.error(e, e.stack);
            globalSettings = Globals.baseWaveFillColors;
        }
        const config = Utils.mergeConfigs(Globals.baseWaveFillColors, waveFillColors);
        const configStr = JSON.stringify(config);
        if (Plasmoid.configuration.waveFillColors !== configStr) {
            Plasmoid.configuration.waveFillColors = configStr;
            Plasmoid.configuration.writeConfig();
        }
        return config;
    }

    property var inactiveBlockColorsCfg: {
        let inactiveBlockColors;
        try {
            inactiveBlockColors = JSON.parse(Plasmoid.configuration.inactiveBlockColors);
        } catch (e) {
            logger.error(e, e.stack);
            globalSettings = Globals.baseInactiveBlockColors;
        }
        const config = Utils.mergeConfigs(Globals.baseInactiveBlockColors, inactiveBlockColors);
        const configStr = JSON.stringify(config);
        if (Plasmoid.configuration.inactiveBlockColors !== configStr) {
            Plasmoid.configuration.inactiveBlockColors = configStr;
            Plasmoid.configuration.writeConfig();
        }
        return config;
    }
    property bool drawInactiveBlocks: Plasmoid.configuration.drawInactiveBlocks

    ActivityGate {
        id: activityGate
        values: cava.values
        gateEnabled: root.fadeEnabled
        requirePlayer: root.followPlayers
        playerPlaying: nowPlaying.playing
        delaySeconds: root.fadeDelay
    }

    BeatDetector {
        id: beatDetector
        values: cava.values
        maxRange: main.asciiMaxRange
        stereo: root.stereo
        reverse: Plasmoid.configuration.reverse
        sensitivity: Plasmoid.configuration.bounceSensitivity
        active: root.imageAllowed && root.bounceMode !== Enum.BounceMode.Off && root.fadeLevel > 0
        onBeat: {
            coverLeft.pulse();
            coverRight.pulse();
            coverCenter.pulse();
        }
    }

    // Report the real visualizer size back to main.qml so the bar count and
    // CAVA's ascii range follow the visualizer area, not the whole widget.
    Binding {
        target: main
        property: "visualizerWidth"
        value: visualizer.width
        when: visualizer.width > 0
        restoreMode: Binding.RestoreNone
    }
    Binding {
        target: main
        property: "visualizerHeight"
        value: visualizer.height
        when: visualizer.height > 0
        restoreMode: Binding.RestoreNone
    }

    RowLayout {
        id: content
        opacity: root.fadeLevel
        visible: root.fadeLevel > 0.01
        height: [Enum.Orientation.Left, Enum.Orientation.Right].includes(root.orientation) ? parent.width : parent.height
        width: [Enum.Orientation.Left, Enum.Orientation.Right].includes(root.orientation) ? parent.height : parent.width
        anchors.centerIn: parent
        spacing: root.imageSideLayout ? root.imageSpacing : 0
        CoverImage {
            id: coverLeft
            source: root.coverSource
            bounceMode: root.bounceMode
            bounceStrength: root.bounceStrength
            level: beatDetector.level
            visible: root.imageAllowed && root.imagePosition === Enum.ImagePosition.Left
            Layout.preferredWidth: content.height * root.imageSize / 100
            Layout.preferredHeight: content.height * root.imageSize / 100
            opacity: root.imageOpacity / 100
            animated: !root.gifOnlyWhenPlaying || nowPlaying.playing
            Layout.alignment: Qt.AlignVCenter
        }
        ColumnLayout {
            id: barsColumn
            spacing: 0
                Layout.preferredWidth: {
                    if (circleMode) {
                        return main.minimumDimension;
                    }
                    return (main.horizontal && !Plasmoid.configuration.expanding) ? Plasmoid.configuration.length : -1;
                }
                Layout.preferredHeight: {
                    if (circleMode) {
                        return main.minimumDimension;
                    }
                    return !(main.horizontal && !Plasmoid.configuration.expanding) ? Plasmoid.configuration.length : -1;
                }
                Layout.fillHeight: main.horizontal || Plasmoid.configuration.expanding || [Enum.Orientation.Left, Enum.Orientation.Right].includes(root.orientation) || main.onDesktop
                Layout.fillWidth: !main.horizontal || Plasmoid.configuration.expanding || [Enum.Orientation.Left, Enum.Orientation.Right].includes(root.orientation) || main.onDesktop
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            MarqueeText {
                id: textTop
                Layout.fillWidth: true
                text: root.trackTextValue
                color: root.trackTextColor
                pixelSize: root.trackTextSize
                alignRight: root.trackTextAlignRight
                shown: root.trackTextActive && root.trackTextOnTop
            }

            Visualizer {
                id: visualizer
                visualizerStyle: root.visualizerStyle
                circleMode: root.circleMode
                circleModeSize: root.circleModeSize
                circleModeFill: root.circleModeFill
                barWidth: root.barWidth
                blockHeight: root.blockHeight
                blockSpacing: root.blockSpacing
                barGap: root.barGap
                centeredBars: root.centeredBars
                waveMode: root.waveMode
                roundedBars: root.roundedBars
                fillWave: root.fillWave
                barColorsCfg: root.barColorsCfg
                waveFillColorsCfg: root.waveFillColorsCfg
                inactiveBlockColorsCfg: root.inactiveBlockColorsCfg
                drawInactiveBlocks: root.drawInactiveBlocks
                waveSimulateWaveform: root.waveSimulateWaveform
                waveform: root.waveform
                values: {
                    let values = [...cava.values];
                    if (circleMode && root.stereo) {
                        return Utils.swapChannels(values);
                    }
                    if (root.visualizerStyle === Enum.VisualizerStyles.Wave && root.pinnedDownSides && !root.circleMode && !root.waveform) {
                        values[0] = 0;
                        values[values.length - 1] = 0;
                    }
                    return values;
                }
                debugMode: Plasmoid.configuration.debugMode
                visible: !cava.hasError && !cava.idle
                fixVertical: !main.horizontal
                Layout.fillWidth: true
                Layout.fillHeight: true

                property var orientationBottom: Rotation {
                    origin.x: Math.floor(visualizer.width / 2)
                    origin.y: Math.floor(visualizer.height / 2)
                    axis {
                        x: 1
                        y: 0
                        z: 0
                    }
                    angle: 0
                }
                property var orientationTop: Rotation {
                    origin.x: Math.floor(visualizer.width / 2)
                    origin.y: Math.floor(visualizer.height / 2)
                    axis {
                        x: 1
                        y: 0
                        z: 0
                    }
                    angle: 180
                }
                property var orientationLeft: Rotation {
                    origin.x: Math.floor(visualizer.width / 2)
                    origin.y: Math.floor(visualizer.height / 2)
                    angle: 90
                }
                property var orientationRight: Rotation {
                    origin.x: Math.floor(visualizer.width / 2)
                    origin.y: Math.floor(visualizer.height / 2)
                    angle: -90
                }
                transform: {
                    let t = [];
                    if (main.orientation === Enum.Orientation.Top) {
                        t.push(orientationTop);
                    }
                    if (main.orientation === Enum.Orientation.Left) {
                        t.push(orientationLeft);
                    }
                    if (main.orientation === Enum.Orientation.Right) {
                        t.push(orientationRight);
                        t.push(orientationTop);
                    }
                    return t;
                }
            }

            MarqueeText {
                id: textBottom
                Layout.fillWidth: true
                text: root.trackTextValue
                color: root.trackTextColor
                pixelSize: root.trackTextSize
                alignRight: root.trackTextAlignRight
                shown: root.trackTextActive && !root.trackTextOnTop
            }
        }
        CoverImage {
            id: coverRight
            source: root.coverSource
            bounceMode: root.bounceMode
            bounceStrength: root.bounceStrength
            level: beatDetector.level
            visible: root.imageAllowed && root.imagePosition === Enum.ImagePosition.Right
            Layout.preferredWidth: content.height * root.imageSize / 100
            Layout.preferredHeight: content.height * root.imageSize / 100
            opacity: root.imageOpacity / 100
            animated: !root.gifOnlyWhenPlaying || nowPlaying.playing
            Layout.alignment: Qt.AlignVCenter
        }
        Kirigami.Icon {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.preferredWidth: Kirigami.Units.iconSizes.roundedIconSize(Math.min(main.height, main.width))
            Layout.fillHeight: Layout.preferredWidth
            source: Qt.resolvedUrl("./icons/error.svg").toString().replace("file://", "")
            active: mouseArea.containsMouse
            isMask: true
            color: Kirigami.Theme.negativeTextColor
            visible: cava.hasError
        }
    }

    // Centered mode: the image floats over the middle of the visualizer
    CoverImage {
        id: coverCenter
        anchors.centerIn: parent
        width: Math.min(root.width, root.height) * root.imageSize / 100
        height: width
        source: root.coverSource
        bounceMode: root.bounceMode
        bounceStrength: root.bounceStrength
        level: beatDetector.level
        visible: root.imageAllowed && root.imagePosition === Enum.ImagePosition.Center && root.fadeLevel > 0.01
        opacity: root.imageOpacity / 100 * root.fadeLevel
        animated: !root.gifOnlyWhenPlaying || nowPlaying.playing
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: enabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            main.expanded = !main.expanded;
        }
        enabled: !root.disableLeftClick || cava.hasError || main.expanded
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainItem: Tooltip {}
        active: !Plasmoid.configuration.hideToolTip
    }
}
