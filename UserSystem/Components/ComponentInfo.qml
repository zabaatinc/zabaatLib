import QtQuick 2.5
QtObject {
    id : rootObject
    property var component
    property alias source : rootObject.component
    property string valueProperty : 'text'
    property string labelProperty : 'label'
}
