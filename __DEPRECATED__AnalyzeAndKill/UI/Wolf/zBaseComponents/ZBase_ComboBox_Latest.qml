import QtQuick 2.0
import QtQuick.Window 2.0

Item
{
    id : rootObject
    width  : 100
    height : 62
    property int maxCells : 4
    property alias model : list.model
    property alias currentIndex : list.currentIndex
    signal isDying(var obj)
    Component.onDestruction: isDying(this)
    property var self : this

    ZBase_TextBox
    {
        id : valShower
        width : parent.width
        height : parent.height
        isEnabled: false
        onActiveFocusChanged: if(!activeFocus || !focus) list.visible = false


        MouseArea
        {
            anchors.fill: parent
            onClicked :
            {
                list.visible = !list.visible
            }
        }
    }

    onCurrentIndexChanged:
    {
        valShower.text = lModel.get(currentIndex).TEXT
    }


    ListView
    {
        id : list
        width : parent.width
        height : maxCells * parent.height
        clip : true
        anchors.top : valShower.bottom
        visible : false

        onActiveFocusChanged: if(!activeFocus || !focus) list.visible = false

        spacing: 2
        model : ListModel
        {
            id : lModel
        }

        delegate : Component
        {
            ZBase_TextBox
            {
                width     : rootObject.width - 20
//                radius    : width /4
                height    : index == currentIndex ? 0     : rootObject.height - 10
                font.pointSize: 12
                isEnabled : false
                text      : TEXT
                visible   : index == currentIndex ? false : true
                color     : "grey"

                MouseArea
                {
                    anchors.fill: parent
                    onClicked : { list.currentIndex = index; list.visible = false }
                    hoverEnabled : true
                    onEntered : parent.color = "green"
                    onExited  : parent.color = "grey"
                }

                onTextChanged:
                {
                    if(index == currentIndex)
                        valShower.text = lModel.get(index).TEXT
                }
            }
        }
    }
}






