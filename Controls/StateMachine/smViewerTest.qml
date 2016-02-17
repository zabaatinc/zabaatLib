import QtQuick 2.5
import Zabaat.Controls.StateMachine 1.0
import QtQuick.Window 2.2
import Zabaat.Utility.FileIO 1.0
import QtQuick.Controls 1.4


Window {
    id : mainWindow
    width : Screen.width /2
    height : Screen.height - 300
    x : 0

    StateMachineViewer {
        id : smv
        anchors.fill : parent
        stateMachine : stateMachines.get(0) ? stateMachines.get(0) : null
        modelObject  : ticketObjects.get(0) ? ticketObjects.get(0) : null

        onCurrentStateChanged: sme.gui.setActiveState(currentState)
        Keys.onBackPressed: smv.logic.back()

        Button {
            text : "<--"
            onClicked : smv.logic.back()
        }
    }

    Window {
        width : Screen.width /2
        height : Screen.height - 300
        x      : mainWindow.width
        y      : mainWindow.y
        visible : true
        StateMachineEditor {
            id: sme
            anchors.fill: parent
            enabled     : false
            model       : stateMachines.get(0) ? stateMachines.get(0) : null
//            onModelChanged: console.log(JSON.stringify(model,null,2))
        }
    }

    Component.onCompleted: {
         x = 0;
        var tObj = { id : "1234", state : "unborn" }
        ticketObjects.append(tObj)
        smv.modelObject = ticketObjects.get(0)

        var url = Qt.resolvedUrl("ticket.json").toString()
        url = url.replace("file://","")
        if(url.indexOf("/") === 0)
            url = url.slice(1)

        var txt = zfileio.readFile(url)
        try {
            var obj = JSON.parse(txt);
            stateMachines.append(obj);
            smv.stateMachine = sme.model = stateMachines.get(0)
            sme.gui.setActiveState(smv.currentState)
        }
        catch(e) {
            console.error("Could not parse js", e, txt);
        }
    }


    ListModel {  id : ticketObjects; dynamicRoles : true }
    ListModel {  id : stateMachines; dynamicRoles: true  }
    ZFileOperations { id : zfileio }
}
