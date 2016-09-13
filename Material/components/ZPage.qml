import QtQuick 2.5
import Zabaat.Material 1.0
Item {
    id : rootObject
    property string title : ""
    objectName     : title
    width          : 100
    height         : 100
    implicitWidth  : Units.defaultWidth
    implicitHeight : Units.defaultHeight

    property point scaleMultiplier : Qt.point(1,1);

    QtObject {
        id: logic
        property real wMulti : (rootObject.width  / rootObject.implicitWidth)   * scaleMultiplier.x
        property real hMulti : (rootObject.height / rootObject.implicitHeight)  * scaleMultiplier.y

        //property real aspectRatio : wMulti / hMulti
    }

    function wx(px)        { return px * logic.wMulti }
    function hx(px)        { return px * logic.hMulti }
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
