import QtQuick 2.5
import QtQuick.Controls 1.4
import "../../CacheView"

Rectangle {
    color : 'blue'
    border.width: 1
    height : cellHeight * 1.25
    property int cellHeight : 200

    signal changed();
    signal deleteMe();

    property var m
    property var availableVars
    property bool hasInit : false
    property bool componentsReady : varsBox.ready && opsBox.ready && ti.ready
    onMChanged: logic.init()
    onComponentsReadyChanged: logic.init()



    QtObject {
        id : logic
        function init(){
            if(m && componentsReady) {
                hasInit = false;

                ti.text = m.val;
                logic.setCombo(varsBox,m.key)

                var op = m.op === "==" ? "equals" : m.op === "!=" ? "not Equals" : m.op
                logic.setCombo(opsBox , op);

                hasInit = true;
            }
            else {
                hasInit = false;
            }
        }

        function process(){
            m.key = varsBox.currentText;
            m.op  = opsBox.currentText === "equals" ? "==" : opsBox.currentText === "not Equals" ? "!=" : opsBox.currentText
            m.val = !isNaN(ti.text) ? parseFloat(ti.text) : ti.text;
            changed();
        }

        //sets combo box to this val.
        function setCombo(box, val){
            for(var i = 0; i < box.model.length; ++i){
                if(box.model[i] === val)
                    return box.currentIndex = i;
            }
        }
    }

    Row {
        anchors.fill: parent
        anchors.margins: cellHeight/8
        ComboBox {
            id : varsBox
            model  : availableVars
            width  : parent.width * 0.25
            height : parent.height * 0.95
            anchors.verticalCenter: parent.verticalCenter
            onCurrentTextChanged : {
                if(!m || !hasInit)
                    return;

                logic.process()
            }
            property bool ready : false
            Component.onCompleted: ready = true
        }
        ComboBox {
            id: opsBox
            model  : ["equals","not Equals",">",">=","<","<=","contains"]
            width  : parent.width * 0.25
            height : parent.height * 0.95
            anchors.verticalCenter: parent.verticalCenter
            onCurrentTextChanged : {
                if(!m || !hasInit)
                    return;

                logic.process();
            }
            visible: varsBox.currentText !== ""
            property bool ready : false
            Component.onCompleted: ready = true
        }
        Rectangle {
            width  : Math.max(parent.width * 0.25 , ti.contentWidth + 5)
            height : parent.height * 0.95
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            TextInput {
                id :ti
                anchors.centerIn: parent
                font.pixelSize: height * 1/2
                width  : parent.parent.width * 0.24
                height : parent.height
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                onTextChanged : {
                    if(!m || !hasInit)
                        return;

                    logic.process();
                }
                property bool ready : false
                Component.onCompleted: ready = true
            }
            visible : opsBox.visible
        }
    }


    SimpleButton {
        width     : cellHeight * 2.5
        height    : parent.height
        anchors.verticalCenter: parent.verticalCenter
        text      : "x Delete"
        color     : colors.danger
        textColor : 'white'
        onClicked : deleteMe();
        anchors.right: parent.right
    }

    Colors{ id : colors }

}
