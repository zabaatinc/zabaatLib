import QtQuick 2.4
import Zabaat.Material 1.0
FocusScope {
    id : rootObject
    property var target : null
    property int cellHeight : 64
    onTargetChanged: if(target){
//                        console.log(target, JSON.stringify(target,null,2))
                        nameBox.text = target.name

                         if(target.anim)
                            target.anim.start()

                        logic.loadModel(target)
                     }

    property var propertyName : "transitions"
    property bool dontsave : false
    signal finished()

    function finish(dontsave){
//        console.log("FINISH CALLED")
        if(dontsave === null || typeof dontsave === 'undefined')
            dontsave = rootObject.dontsave

        if(!dontsave && target && target.rules) {
            target.rules = getJSON()
        }

        if(target && target.anim)
            target.anim.stop()
//        target = null

//        nameBox.text = ""
//        lm.clear()

        finished()
    }

    function getJSON(){
        var obj = []
        if(lv.model){
            for(var i = 0; i < lv.model.count; i++){
                var item = lv.model.get(i)
                obj.push({  name : item.name,
                            type : item.type,
                             choices : item.choices,
                             isRequired : item.isRequired
                         })
            }
        }


        return obj
    }


    Keys.onEscapePressed: finish()

    Item {
        id : bigTop
        width : parent.width
        height : cellHeight
        objectName : "BIG T"
        focus : false


        ZTextBox {
            id            : nameBox
            label         : "Name"
            onTextChanged : if(target)
                                target.name = text;
            focus : true
            validationFunc: function(text){
                if(!target || !target.origin || !target.origin[propertyName])
                    return null;

                for(var i = 0; i < target.origin[propertyName].children.length; i++){
                    var item = target.origin[propertyName].children[i]
                    if(item === target)
                        continue
                    else if(item.name === target.name)
                        return "Name already exists!"
                }
                return null;
            }
            width  : parent.width * 0.7
            height : parent.height
            onAccepted: finish()
            state : "f2-t2"
        }
        Row {
            width : parent.width * 0.2
            height : parent.height
            anchors.right: parent.right
            ZButton {
                width : parent.width * 0.5
                height : parent.height
                text : "+"
                state : "success-f2"
                onClicked : logic.add()
            }
            ZButton {
                width : parent.width * 0.5
                height : parent.height
                text : "-"
                state : "success-f2"
                onClicked : logic.del()
            }
        }
    }


    Item {
        id : header
        objectName : "header"
        width  : lv.width
        height : cellHeight
        anchors.top: bigTop.bottom
        focus : false

        Row {
           width  : lv.width
           height : cellHeight/2
           anchors.bottom: parent.bottom

           spacing : 2
           visible : lv.model && lv.model.count > 0
           ZButton {
               enabled : false
               disableShowsGraphically: false
               width      : parent.width * lv.wArr[1]
               height     : parent.height
               text       : "Name"
               state      : "success-f2-t2"
           }
           ZButton {
               enabled : false
               disableShowsGraphically: false
               width  : parent.width * lv.wArr[2]
               height     : parent.height
               text   : "Type"
               state      : "success-f2-t2"
           }
           ZButton {
               enabled : false
               disableShowsGraphically: false
               width  : parent.width * lv.wArr[3]
               height     : parent.height
               text   : "Choices"
               state      : "success-f2-t2"
           }
           ZButton {
               enabled : false
               disableShowsGraphically: false
               width  : parent.width * lv.wArr[4]
               height     : parent.height
               text   : "Required"
               state      : "success-f2-t2"
           }
        }
    }


    ListView {
        id : lv
        width  : parent.width
        height : parent.height - cellHeight - header.height
        anchors.bottom: parent.bottom
        model : lm
        ListModel { id : lm;   dynamicRoles : true   }
        focus : false
        objectName : "LV"

        property var wArr : [0.1,
                             0.3,
                             0.2,
                             0.4,
                             0.1,
                            ]

        delegate: FocusScope{
            id : delegate
            width  :lv.width
            height :cellHeight
            objectName : "Delegate"

            property var m   : lv.model ? lv.model.get(index) : null
            focus            : false
            activeFocusOnTab : false


            ZButton {
                id : cursor
                enabled : false
                text : ">"
                height: parent.height
                width : parent.width * lv.wArr[0]
                opacity : lv.currentIndex === index  ? 1 : 0
                state : 'transparent-t2'
                anchors.right: parent.left
            }

            Row {
                anchors.fill: parent
                spacing : 2

                focus : false

                ZTextBox {
                    id : first
                    state      : "f3-t2-nolabel"
                    label      : "Name"
                    width      : parent.width * lv.wArr[1]
                    height     : cellHeight
                    text       : delegate && delegate.m  ? delegate.m.name : ""
                    setAcceptedTextFunc : function(val) { delegate.m.name = val ; }
                    onActiveFocusChanged: if(activeFocus) lv.currentIndex = index
                }
                ZTextBox {
                    state  : "f3-t2-nolabel"
                    label  : "Type"
                    width  : parent.width * lv.wArr[2]
                    height : cellHeight
                    text   : delegate && delegate.m  ? delegate.m.type : ""
                    setAcceptedTextFunc : function(val) { delegate.m.type = val ; }
                    onActiveFocusChanged: if(activeFocus) lv.currentIndex = index
                }
                ZTextBox {
                    state  : "f3-t2-nolabel"
                    label  : "Choices"
                    width  : parent.width * lv.wArr[3]
                    height : cellHeight
                    text   : delegate && delegate.m  ? delegate.m.choices : ""
                    setAcceptedTextFunc : function(val) { delegate.m.choices = val ; }
                    onActiveFocusChanged: if(activeFocus) lv.currentIndex = index
                }

                Rectangle {
                    width  : parent.width * lv.wArr[4]
                    height : cellHeight
                    border.width: activeFocus ? 1  : 0
                    border.color : Colors.success

                    color : 'transparent'
                    focus : true
                    activeFocusOnTab: true
                    Keys.onReturnPressed: delegate.m.isRequired = !delegate.m.isRequired
                    Keys.onEnterPressed: delegate.m.isRequired = !delegate.m.isRequired

                    ZButton {
                        id : last
                        state  : delegate && delegate.m  && !delegate.m.isRequired ? "transparent" : "success"
                        text   : ''
                        anchors.fill: parent
                        scale : 0.5
                        onClicked: delegate.m.isRequired = !delegate.m.isRequired
                    }
                }
            }

        }
    }


    Row {
        id: finalRow
        anchors.top: parent.bottom
        width : parent.width/4
        height : cellHeight
        anchors.horizontalCenter: parent.horizontalCenter

        ZButton {
            text   : 'Cancel'
            state  : "danger-f2"
            width  : parent.width/2
            height : parent.height
            onClicked : finish(true)
        }
        ZButton {
            text   : 'OK'
            state  : "success-f2"
            width  : parent.width/2
            height : parent.height
            onClicked : finish()
        }
    }

    QtObject{
        id : logic

        function loadModel(target){
            var rules = target.rules
            if(rules.toString().toLowerCase().indexOf('listmodel') === -1) {
                lm.clear()
                if(rules && rules.length > 0){
                    lm.append(rules)
                }
            }
            else {
                lv.model = rules
            }
        }
        function add(){
            if(lv.model)
                lv.model.append({name:"",type:"",choices:"",isRequired:false })
        }
        function del(){
            if(lv.model)
                lv.model.remove(lv.currentIndex)
        }
    }


}
