import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Visualizer")
        icon: "waveform-symbolic"
        source: "configVisualizer.qml"
    }
    ConfigCategory {
        name: i18n("Image")
        icon: "image-x-generic-symbolic"
        source: "configCover.qml"
    }
    ConfigCategory {
        name: i18n("Now playing")
        icon: "media-playback-start-symbolic"
        source: "configNowPlaying.qml"
    }
    ConfigCategory {
        name: i18n("Idle fade")
        icon: "view-hidden"
        source: "configFade.qml"
    }
    ConfigCategory {
        name: "CAVA"
        icon: "view-process-system-symbolic"
        source: "configCava.qml"
    }
    ConfigCategory {
        name: i18n("General")
        icon: "configure-symbolic"
        source: "configGeneral.qml"
    }
}
