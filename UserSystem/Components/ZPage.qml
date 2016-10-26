import QtQuick 2.5
import QtQuick.Window 2.0
Item {
    id : rootObject
    property string title : ""
    objectName     : title
    width          : 100
    height         : 100
    property point sizeDesigner    : Qt.point(750,1254);
    property point sizeMainWindow  : Qt.point(Screen.width, Screen.height)
    property point scaleMultiplier : Qt.point(1,1);
    property bool  absoluteMode    : true       //determines if we are calculating our hx,wx in mainWindow's w/h or this Item's!

    QtObject {
        id: logic
        property real wMulti    : (rootObject.width  / sizeDesigner.x)  * scaleMultiplier.x
        property real hMulti    : (rootObject.height / sizeDesigner.y)  * scaleMultiplier.y
        property real wMultiAbs : (sizeMainWindow.x  / sizeDesigner.x)  * scaleMultiplier.x
        property real hMultiAbs : (sizeMainWindow.y  / sizeDesigner.y)  * scaleMultiplier.y

        //property real aspectRatio : wMulti / hMulti
    }

    function wx(px)        { return Math.min(sizeMainWindow.x , absoluteMode ? px * logic.wMultiAbs : px * logic.wMulti) }
    function hx(px)        { return Math.min(sizeMainWindow.y , absoluteMode ? px * logic.hMultiAbs : px * logic.hMulti) }
    function point(w,h)    { return Qt.point(wx(w) , hx(h)) }
    function rect(x,y,w,h) { return Qt.rect(wx(x) , hx(y), wx(w), hx(h)) }
    function bindItem(item,x,y,w,h) {   //
        if(item) {
            if(x !== undefined)     item.x      = Qt.binding(function() { return wx(x) })
            if(y !== undefined)     item.y      = Qt.binding(function() { return hx(y) })
            if(w !== undefined)     item.width  = Qt.binding(function() { return wx(w) })
            if(h !== undefined)     item.height = Qt.binding(function() { return hx(h) })
        }
    }

    function bindPoint(item,x,y) {
        if(item) {
            if(x !== undefined)     item.x      = Qt.binding(function() { return wx(x) })
            if(y !== undefined)     item.y      = Qt.binding(function() { return hx(y) })
        }
    }
    function bindSize(item,w,h) {
        if(item) {
            if(w !== undefined)     item.width  = Qt.binding(function() { return wx(w) })
            if(h !== undefined)     item.height = Qt.binding(function() { return hx(h) })
        }
    }
    function bindItemRememberRatio(item,x,y,w,h) {
        bindPoint(item,x,y)
        bindSizeRememberRatio(item,w,h)
    }
    function bindSizeRememberRatio(item,w,h) {
        if(item) {

           if(w !== undefined) {

               item.width = Qt.binding(function() {
                   var width             = wx(w)
                   var height            = hx(h)
                   var canvasAspectRatio = width / height
                   var imageAspectratio  = w/h
                   return imageAspectratio < canvasAspectRatio ? (height/h) * w : width
               })


           }
           if(h !== undefined) {

               item.height = Qt.binding(function() {
                   var width             = wx(w)
                   var height            = hx(h)
                   var canvasAspectRatio = width / height
                   var imageAspectratio  = w/h
                   return imageAspectratio > canvasAspectRatio ? (width/w) * h : height
               })

           }
        }
    }





}
