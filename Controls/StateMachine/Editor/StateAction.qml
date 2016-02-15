import QtQuick 2.4
Item {
    property string name : ""
    property var origin  : null
    property var rules   : []
    function getJSON(){
        return { name : name, rules : rules }
    }
}
