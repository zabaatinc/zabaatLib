import QtQuick 2.4
import Zabaat.Material 1.0
import "ZSpinner"

//Default button, flat style
//Uses the 'magic' path from https://wiki.qt.io/Qt_Quick_Carousel
Rectangle {
    id : rootObject
    property DefaultDelegateOptions defaultDelegate : DefaultDelegateOptions
    {
      width : cellHeight;
      height : cellHeight
    }
    property alias pv                 : pv
    property alias model              : pv.model
    property alias currentIndex       : pv.currentIndex
    property alias currentItem        : pv.currentItem
    property alias delegate           : pv.delegate
    property int cellHeight           : rootObject.height * 0.1
    property alias path               : pv.path
    property alias interactive        : pv.interactive
    property alias highlightRangeMode : pv.highlightRangeMode
    property bool  isStatic           : false
    property alias pathMargin         : pv.pathMargin
    property alias animSpeed          : pv.highlightMoveDuration
    radius : height/2
    color : 'transparent'
    border.width: 5

    PathView {
        id : pv
        anchors.fill: parent
        path        : defaultPath
        delegate    : btnCmp

        property int pathMargin: 0
        property real rx: ry // view.width / 2 - pathMargin
        property real ry: cy - pathMargin
        property real magic: 0.551784
        property real mx: rx * magic
        property real my: ry * magic
        property real cx: pv.width  / 2
        property real cy: pv.height / 2

        highlightRangeMode: isStatic ? PathView.NoHighlightRange : PathView.StrictlyEnforceRange
        interactive       : !isStatic

        Path {
            id : defaultPath
            startX: pv.cx + pv.rx; startY: pv.cy
            PathCubic { // first quadrant arc
                control1X: pv.cx + pv.rx; control1Y: pv.cy + pv.my
                control2X: pv.cx + pv.mx; control2Y: pv.cy + pv.ry
                x: pv.cx; y: pv.cy + pv.ry
            }
            PathCubic { // second quadrant arc
                control1X: pv.cx - pv.mx; control1Y: pv.cy + pv.ry
                control2X: pv.cx - pv.rx; control2Y: pv.cy + pv.my
                x: pv.cx - pv.rx; y: pv.cy
            }
            PathCubic { // third quadrant arc
                control1X: pv.cx - pv.rx; control1Y: pv.cy - pv.my
                control2X: pv.cx - pv.mx; control2Y: pv.cy - pv.ry
                x: pv.cx; y: pv.cy - pv.ry
            }
            PathCubic { // forth quadrant arc
                control1X: pv.cx + pv.mx; control1Y: pv.cy - pv.ry
                control2X: pv.cx + pv.rx; control2Y: pv.cy - pv.my
                x: pv.cx + pv.rx; y: pv.cy
            }
        }

        Component {
            id : btnCmp
                ZButton {
                id : delItem
                width     : defaultDelegate.width
                height    : defaultDelegate.height
                text      : defaultDelegate.displayFunc ? defaultDelegate.displayFunc(index,model) : index
                onClicked : pv.currentIndex = index
                enabled   : pv.currentIndex !== index
                disableShowsGraphically: false
                state   : !enabled ? defaultDelegate.state_Selected : defaultDelegate.state_UnSelected
                z : !enabled ? pv.count + 1 : 0
            }
        }
    }


}
