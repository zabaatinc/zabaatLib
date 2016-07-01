import QtQuick 2.5
Rectangle {
    radius : Math.min(width,height) * 1/4
    border.width: 1
    NumberAnimation on opacity { from : 0; to : 1; duration : 1000; running : true }
}
