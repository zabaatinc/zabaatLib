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


    onChildrenChanged: {
        for(var i = children.length - 1; i >= 0 ; i--)
        {
            var child = children[i]
            if(!child.hasOwnProperty('nokidnap'))
                child.parent = foldable
        }
    }


    ZBase_Foldable
    {
        id : foldable
        property bool nokidnap : true
        width : parent.width
        height : parent.height
    }

    ZBase_Button
    {
        id : foldUnfoldBtn
        text : ""
        showIcon : true
        fontAwesomeIcon: folded ? foldIcon : unfoldIcon
        property bool nokidnap : true
        onBtnClicked: folded = !folded
    }
}





