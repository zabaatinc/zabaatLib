import QtQuick 2.4
import Zabaat.Misc.Global 1.0

Rectangle {     //WORK IN PROGRESS
    id     : rootObject
    width  : 200
    height : 300
    radius : 5

    signal click     (var self)
    signal clicked   (var self)
    signal btnClicked(var self)
    signal hovered   (var self)
    signal unhovered (var self)

    //*****************z component reserved
     property var self : this
    signal isDying(var obj)
    Component.onDestruction: isDying(this)
    property var uniqueProperties : ["text","fontSize","fillColor","textColor","pressedBorder","activeBorder","pressedFill","hoverFill","glowColor","imgSrc"]
    property var uniqueSignals	  : ({btnClicked:[]})
    //*********************

    Keys.onEnterPressed : btnClicked(rootObject)
    Keys.onReturnPressed: btnClicked(rootObject)

//    property alias text : text





}
