import QtQuick 2.4
Item {
    property var    model     : null
    property string stateName : model ? model.state : ""
    onStateNameChanged: console.log(this, stateName)
}
