//Components dropped in should have property string title : ""
//If a custom header delegate is provided & if it doesn't have a onClicked signal ,
//we will add a mouseArea to it
import QtQuick 2.5
import Zabaat.Material 1.0
ZObject {
    id : rootObject
    objectName : "ZSwipeView"
    clip : true

    property var headerDelegate : null
    property int currentIndex   : -1










}
