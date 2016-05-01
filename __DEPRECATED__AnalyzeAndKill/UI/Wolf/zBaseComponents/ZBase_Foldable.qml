import QtQuick 2.0
import QtQuick.Window 2.0

/*! Basic foldable component, compresses its children*/
Rectangle
{
    id : rootObject
    color : "transparent"
    visible : true
    width  : 400
    height : 400

    property var self : this
    //*****************z component reserved
    signal isDying(var obj)
    Component.onDestruction: isDying(this)
    property var uniqueProperties : ["folded","foldsOnX","foldsOnY","foldSpeed","affectVisibility","transformOriginX","transformOriginY","giveFocusToChildOnExpand"]
    property var uniqueSignals	  : ({})
    //*********************

    property bool folded    : false
    property bool foldsOnX  : true
    property bool foldsOnY  : false
    property int  foldSpeed : 500
    property bool affectVisibility : false
    property alias transformOriginX : scaleTrans.origin.x
    property alias transformOriginY : scaleTrans.origin.y

    readonly property alias scaleX : scaleTrans.xScale
    readonly property alias scaleY : scaleTrans.yScale


    property bool giveFocusToChildOnExpand : true

    transform: Scale{ id : scaleTrans }
    clip : true
    Component.onCompleted: { if(folded) shrink.start(); else grow.start() }
    onFoldedChanged:       { if(folded) shrink.start(); else grow.start() }



    property Item privates : Item{
        id : privates
        property alias xScl : scaleTrans.xScale
        property alias yScl : scaleTrans.yScale

        function myProperties(){
            if(foldsOnX && foldsOnY)       return "xScl,yScl"
            else if(foldsOnX)              return "xScl"
            else if(foldsOnY)              return "yScl"
            else                           return ""
        }


        NumberAnimation
        {
            id        : shrink
            properties: privates.myProperties()
            target    : privates
            to        : 0
            duration  : foldSpeed
            onStarted : if(grow.running)  grow.stop()
            onStopped : {
                if(affectVisibility)
                    rootObject.visible = false

                if(giveFocusToChildOnExpand)
                    rootObject.forceActiveFocus()
            }
        }

        NumberAnimation
        {
            id : grow
            properties: privates.myProperties()
            target    : privates
            to        : 1
            duration  : foldSpeed

            onStarted : if(shrink.running)  shrink.stop()
            onStopped :{
                rootObject.visible = true
                if(giveFocusToChildOnExpand && rootObject.children.length > 0)
                    rootObject.children[0].forceActiveFocus()
            }
        }




    }




}


