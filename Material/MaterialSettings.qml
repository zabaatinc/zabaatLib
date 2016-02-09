import QtQuick 2.4
import Zabaat.Material 1.0
import QtQuick.Window 2.2

pragma Singleton
Item {
    property bool  editMode      : false
    property alias font          : settings_Font
    property alias style         : settings_Style
    property alias units         : settings_Units
    readonly property bool loaded: Fonts.loaded && Colors.loaded

    function init(){
        if(!__privates.hasInit){

            Fonts.font1        = font.font1
            Fonts.font2        = font.font2
            Fonts.dir          = font.dir
            Colors.dir         = style.colorsPath
            Colors.defaultColorTheme = style.defaultColors
            Units.pixelDensity = units.pixelDensity = Screen.pixelDensity
            Units.multiplier   = units.scaleMulti

            __privates.hasInit = true
        }
    }

    QtObject {
        id : settings_Font
        property string dir  : Qt.resolvedUrl("./fonts")
        property string font1: "FontAwesome"
        property string font2: "Arial"
        onDirChanged         : Fonts.dir = font.dir
    }

    QtObject {
        id : settings_Style
        property string skinsPath    : Qt.resolvedUrl("./components/skins/")
        property string colorsPath   : Qt.resolvedUrl("./components/colors/")
        property string defaultColors: "default"
        property string defaultSkin  : "default"

        onColorsPathChanged   : Colors.dir = colorsPath
        onDefaultColorsChanged: Colors.defaultColorTheme = defaultColors
    }

    QtObject {
        id : settings_Units
        property real pixelDensity : 4.3
        property real scaleMulti   : 1.45

        onPixelDensityChanged: Units.pixelDensity = pixelDensity
        onScaleMultiChanged: Units.multiplier     = scaleMulti
    }

    QtObject {
        id : __privates
        property bool hasInit : false
    }


    Component.onCompleted: init()


}
