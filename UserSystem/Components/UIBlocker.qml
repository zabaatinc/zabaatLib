import QtQuick 2.5
Item {
    id : blocker
    visible : false;

    onVisibleChanged: if(visible)
                          forceActiveFocus();

    property alias fillColor   : blockerFill.color
    property alias fillOpacity : blockerFill.opacity
    property var   text     : [".","..","..."]
    property alias textSize : blockerText.font.pointSize
    property alias textColor: blockerText.color

    onTextChanged: {
        if(toString.call(text) === '[object Array]' && text.length > 0){
            blockerText.text = text[0];
        }
        else if(typeof text !== 'object')
            blockerText.text = text.toString();
    }

    Rectangle {
        id : blockerFill
        anchors.fill: parent
        color : 'black'
        opacity : 0.8
    }

    Text {
        id : blockerText
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color : "white"
    }

    Timer {
        running : blocker.visible
        repeat : true
        interval : 500
        property int itr : 0
        onTriggered: {
            if(toString.call(text) !== '[object Array]')
                return;

            itr++;
            if(itr >= text.length)
                itr = 0;
            blockerText.text = text[itr].toString();
        }
    }


}
