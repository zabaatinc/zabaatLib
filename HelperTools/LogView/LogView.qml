import QtQuick 2.5
import Zabaat.Base 1.0
import Zabaat.Utility.SubModel 1.1
Item {
    id : rootObject

    Item {
        id : logic
        property var logs : Functions && Functions.logs ? Functions.logs : null;
        onLogsChanged: {
            sourceLogs.clear();
            sourceWarnings.clear();
            sourceErrors.clear();

            if(logs) {
                Lodash.each(logs.logs()    , function(l) { sourceLogs.append(l)     })
                Lodash.each(logs.warnings(), function(l) { sourceWarnings.append(l) })
                Lodash.each(logs.errors()  , function(l) { sourceErrors.append(l)   })
            }
        }

        Connections {
            target         : logic.logs ? logic.logs : null;
            onLogAdded     : sourceLogs.append(log);
            onWarningAdded : sourceWarnings.append(warning);
            onErrorAdded   : sourceErrors.append(error);
        }


        function timeSortFn(a,b) { return a.ts.getTime() - b.ts.getTime(); }

        ZSubModel {
            id : s_logs
            sourceModel: ListModel { id : sourceLogs; dynamicRoles: true }
            sortFunc: logic.timeSortFn
        }
        ZSubModel {
            id : s_warnings
            sourceModel: ListModel { id : sourceWarnings; dynamicRoles: true }
            sortFunc: logic.timeSortFn
        }
        ZSubModel {
            id : s_errors
            sourceModel: ListModel { id : sourceErrors; dynamicRoles: true }
            sortFunc: logic.timeSortFn
        }
    }

    Item {
        id : gui
        anchors.fill: parent
        property int currentIndex : 0

        Row {
            id : topBar
            width : parent.width
            height : parent.height * 0.07

            SimpleButton {
                width : parent.width/3
                height : parent.height
                text     : "Logs (" + s_logs.count + ")"
                onClicked: gui.currentIndex = 0;
                color : 'aqua'
            }
            SimpleButton {
                width : parent.width/3
                height : parent.height
                text     : "Warnings (" + s_warnings.count + ")"
                onClicked: gui.currentIndex = 1;
                color : 'orange'
            }
            SimpleButton {
                width : parent.width/3
                height : parent.height
                text     : "Errors (" + s_errors.count + ")"
                onClicked: gui.currentIndex = 2;
                color : 'red'
            }
        }

        Item {
            id : logList
            width : parent.width
            anchors.top: topBar.bottom
            anchors.bottom: parent.bottom
            clip : true

            LogList {
                anchors.fill: parent
                visible: gui.currentIndex === 0
                model : s_logs
                color : 'aqua'
            }
            LogList {
                anchors.fill: parent
                visible: gui.currentIndex === 1
                model : s_warnings
                color : 'orange'
            }
            LogList {
                anchors.fill: parent
                visible: gui.currentIndex === 2
                model : s_errors
                color : 'red'
            }
        }




    }





}
