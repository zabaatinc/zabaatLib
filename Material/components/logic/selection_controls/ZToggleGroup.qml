import QtQuick 2.5
import Zabaat.Material 1.0

Item {
    id : rootObject
    objectName : "ZToggleGroup"

    property alias group          : lv.model
    property alias orientation    : lv.orientation
    property string stateActive   : "accent-b1-baccent-f3"
    property string stateInactive : "standard-b1-baccent-f3"
    property alias  border        : borderRounder.border
    property alias  radius        : borderRounder.radius
    property var    selected      : {
        if(!lv || !lv.model)
            return undefined;

        if(toString.call(lv.model) === '[object Array]')
            return lv.model[lv.currentIndex]
        else
            return lv.model.get(lv.currentIndex)
    }
    property alias currentIndex    : lv.currentIndex
    property bool  disableShowsGraphically : true

    function selectIdx(idx) {
        return lv.currentIndex = idx;
    }

    function select(item) {
        for(var g in group) {
            if(item === group[g])
                return lv.currentIndex = g
        }
        return false;
    }





    ListView {
        id : lv
        anchors.fill: parent
        orientation : ListView.Horizontal
        interactive : false
        property real w: lv.orientation === ListView.Horizontal ? lv.width / lv.count : lv.width;
        property real h: lv.orientation === ListView.Vertical   ? lv.height/ lv.count : lv.height;
        model : []
        delegate: ZButton {
            width     : lv.w
            height    : lv.h
            onClicked : lv.currentIndex = index;
            text      : modelData
            state     : lv.currentIndex === index ? stateActive : stateInactive
            disableShowsGraphically: rootObject.disableShowsGraphically
        }
//        visible : false
    }



    Rectangle {
        id : borderRounder
        anchors.fill: parent
        radius : height/4
        color  : 'red'
        visible : false
    }

    ShaderEffectSource {
        id : effectSource
        sourceItem: lv
        anchors.fill: parent
        hideSource: true
        visible : false
    }
    ShaderEffectSource {
        id : maskSource
        sourceItem: borderRounder
        anchors.fill: parent
        hideSource: true
        visible : false
    }
    ShaderEffect {
        id : se
        anchors.fill: parent
        property variant source : effectSource
        property variant mask   : maskSource
        fragmentShader:
            "#ifdef GL_ES
                precision mediump float;
             #else
             #   define lowp
             #   define mediump
             #   define highp
             #endif // GL_ES
             uniform sampler2D source;
             uniform sampler2D mask;

             varying vec2       qt_TexCoord0;
             uniform lowp float qt_Opacity;
             void main(){
                 vec2 uv        = qt_TexCoord0.xy;
                 vec4 pixel     = texture2D(source,qt_TexCoord0);
                 vec4 maskPixel = texture2D(mask,qt_TexCoord0);

                 pixel.a = maskPixel.a;
//                 if(maskPixel.a < 1)
//                    pixel = vec4(0.0,0.0,0.0,0.0);

                 gl_FragColor = (pixel) * qt_Opacity;
             }"
    }


    Rectangle {
        id : border
        anchors.fill: parent
        radius : borderRounder.radius
        border.width: borderRounder.border.width
        border.color: borderRounder.border.color
        color : 'transparent'
        z : Number.MAX_VALUE
    }


}
