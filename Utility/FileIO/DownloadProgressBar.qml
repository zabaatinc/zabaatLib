import QtQuick 2.5
Item {
    id : rootObject
    property var zFileDownloaderInstance
    property string url
    onUrlChanged: logic.reset();

    property alias fileName      : logic.fileName
    property alias colorEmpty    : background.color
    property color colorProgress : "orange"
    property color colorFinished : "green"
    property color colorFailed   : "red"
    property alias colorBorder   : borderRect.color
    property alias colorText     : fileNameIndicator.color
    property alias font          : fileNameIndicator.font
    property alias showText      : textArea.visible

    readonly property alias progress: logic.progress

    function startDownload(url, location) {
        if(!zFileDownloaderInstance)
            return false;

        logic.reset();  //reset sets the new time!
        var fname   = location.split("/")
        rootObject.url = url;
        logic.fileName = fname[fname.length-1];

        zFileDownloaderInstance.download(url,location)
    }

    Connections {
        target : zFileDownloaderInstance ? zFileDownloaderInstance : null;
        onDownloadFailed : {
            if(url.toString() === rootObject.url.toString())
                logic.state = 1; //errored!
        }

        onDownloadProgressChanged : {
            if(url.toString() !== rootObject.url.toString()) {
                return;
            }

            logic.elapsed       = ((new Date().getTime()) - logic.startTime.getTime()) / 1000  //seconds
            logic.speed         = speed
            logic.bytesReceived = bytesReceived
            logic.bytesTotal    = bytesTotal
        }
        onDownloadSaved  : {
            if(url.toString() === rootObject.url.toString()) {
                logic.state = 2; //finished
                //saved to fileName
            }

        }
    }

    QtObject {
        id : logic
        property int state : 0
        property real elapsed
        property string speed
        property int bytesReceived
        property int bytesTotal
        property string fileName
        property date   startTime

        property real progress : bytesTotal > 0 ? bytesReceived/bytesTotal : 0

        function reset() {
            state = elapsed = bytesReceived = bytesTotal = 0;
            speed = fileName = ""
            startTime = new Date();
        }
    }

    Item {
        id : gui
        anchors.fill: parent

        Rectangle {
            id : background
            anchors.fill: parent
            Rectangle {
                id : fill
                height : parent.height
                width  : parent.width * progress
                color  : {
                    switch(logic.state) {
                        case 1  : return colorFailed
                        case 2  : return colorFinished
                        default : return colorProgress
                    }
                }
            }
            Rectangle {
                id : borderRect
                anchors.fill: parent
                color : "transparent"
                border.width: 1
            }
        }
        Item {
            id : textArea
            anchors.fill: parent

            Text {
                id : fileNameIndicator
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 5
                text : logic.fileName
            }

            Text {
                id : progressIndicator
                text : (progress.toFixed(1) * 100).toString() + "%"
                anchors.centerIn: parent
                font : fileNameIndicator.font
                color : fileNameIndicator.color
                visible: progress > 0 && logic.state != 2 && logic.bytesTotal !== 0
            }

            Text {
                id : speedIndicator
                font : fileNameIndicator.font
                color : fileNameIndicator.color
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 5
                text : {
                    switch(logic.state) {
                        case 1  : return "Failed"
                        case 2  : var secs = logic.elapsed.toFixed(1);
                                  var mins = (secs / 60).toFixed(1);
                                  var hrs  = (mins / 60).toFixed(1);

                                  var units
                                  if(hrs >= 1) {
                                    units = hrs > 1 ? "hours" : "hour";
                                    return "Finished in " + hrs + " " + units;
                                  }

                                  if(mins >= 1) {
                                    units = mins > 1 ? "minutes" : "minute";
                                    return "Finished in " + mins + " " + units;
                                  }

                                  units = secs > 1 ? "seconds" : "second"
                                  return "Finished in " + secs + " " + units;

                        default : return logic.speed
                    }
                }
            }

        }
    }







}
