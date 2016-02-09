import QtQuick 2.0
import QtQuick.Window 2.0

/*! Basic foldable component, compresses its children*/
Item
{
    id : rootObject
    property var self : this
    //*****************z component reserved
    signal isDying(var obj)
    Component.onDestruction: isDying(this)
    property var uniqueProperties : ["folded","foldsOnX","foldsOnY","foldSpeed","affectVisibility","transformOriginX","transformOriginY","giveFocusToChildOnExpand"]
    property var uniqueSignals	  : ({})
    //*********************

    property string foldIcon   : "\uf0dd"
    property string unfoldIcon : "\uf0de"
    property alias  buttonPtr  : foldUnfoldBtn
    property alias color : foldable.color

    //all these aliases, JEEZUS
    property alias folded    : foldable.folded
    property alias foldsOnX  : foldable.foldsOnX
    property alias foldsOnY  : foldable.foldsOnY
    property alias  foldSpeed : foldable.foldSpeed
    property alias affectVisibility : foldable.affectVisibility
    property alias transformOriginX : foldable.transformOriginX
    property alias transformOriginY : foldable.transformOriginY
    property alias giveFocusToChildOnExpand : foldable.giveFocusToChildOnExpand
    property alias border   : foldable.border
    readonly property alias scaleX : foldable.scaleX
    readonly property alias scaleY : foldable.scaleY


    property bool reportActualWidthAndHeight : true
    onWidthChanged: if(width > 0 && reportActualWidthAndHeight && privates.width == -1) {
                        privates.width = width
                        width = Qt.binding(function() { if(header)  return header.width + (privates.width * scaleX)
                                                        else        return (privates.width * scaleX)
                                                      } )
                    }
//                    else console.log('w',width)

    onHeightChanged: if(height > 0 && reportActualWidthAndHeight && privates.height == -1) {
                        privates.height = height
                        height = Qt.binding(function() { if(header)   return header.height + (privates.height * scaleY)
                                                         else         return (privates.height * scaleY)
                                                       } )
                    }

    QtObject{
        id : privates
        property bool nokidnap : true
        property int width  : -1
        property int height : -1
    }


    onChildrenChanged: {
        for(var i = children.length - 1; i >= 0 ; i--)
        {
            var child = children[i]
            if(!child.hasOwnProperty('nokidnap') && child !== header)
                child.parent = foldable
        }
    }


    ZBase_Foldable
    {
        id : foldable
        property bool nokidnap : true
        width  : privates.width  === -1  ? parent.width  : privates.width
        height : privates.height === -1  ? parent.height : privates.height
        enabled : !folded

//        onWidthChanged: console.log(width)
//        onHeightChanged: console.log(height)
        y : header ? header.height : 0
    }

    property var header : foldUnfoldBtn
    onHeaderChanged: if(header && header.parent !== rootObject) header.parent = rootObject

    ZBase_Button
    {
        id : foldUnfoldBtn
        text : ""
        showIcon : true
        fontAwesomeIcon: folded ? foldIcon : unfoldIcon
        property bool nokidnap : true
        onBtnClicked: folded = !folded
        visible: header === this
        enabled : visible
    }

}





