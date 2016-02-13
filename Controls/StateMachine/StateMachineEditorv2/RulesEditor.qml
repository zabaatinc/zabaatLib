import QtQuick 2.4
import Zabaat.Material 1.0
import "Functions"
FocusScope {
    id : rootObject
    property var target : null
    property int cellHeight : 64
    onTargetChanged: if(target){
                         if(target.anim)
                            target.anim.start()
                     }

    signal nameChanged (string id, string name, var rules)
    signal rulesChanged(string id, string name, var rules)
    signal finished()

    property var vFunc : null
    property bool dontsave : false


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
        return GFuncs.toArray(lv.model)
    }
                        //THe params are only used if the bool is chagned!!!
    function getListJSON(index, boolVal){ //this does not reflect the model!
        var obj = []
        for(var i = 0; i < lv.contentItem.children.length; ++i){
            var child = lv.contentItem.children[i]
            if(child.imADelegate){
                var cObj = {
                    choices : child.choices,
                    required : child.required,
                    name       : child.name,
                    type       : child.type
                }
                //"choices": "a",
                //"required": false,
                //"name": "a",
                //"type": "a"

                if(index === child._index){
                    cObj.required = boolVal
//                    console.log("HAR DONE")
                }
                obj.push(cObj)
            }
        }
//        console.log(JSON.stringify(obj,null,2))
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
            onInputChanged: if(target && text !== oldText)
                                rootObject.nameChanged(target.id, text, getJSON())

//            onTextChanged : rootObject.nameChanged(text,oldText) //if(target)
                             //    target.name = text;
            focus : true
            validationFunc: vFunc
            width  : parent.width * 0.7
            height : parent.height
            state : "f2-t2"
            text  : target && target.name ? target.name : ""
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
        model : target && target.rules ? target.rules : null
//        ListModel { id : lm;   dynamicRoles : true   }
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

            property alias name    : delegate_name.text    //displayOnly
            property alias choices : delegate_choices.text
            property alias type    : delegate_type.text
            property bool required : delegate_requiredBox.state === "success"
            property bool imADelegate : true
            property int _index       : index

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
                    id : delegate_name
                    state      : "f3-t2-nolabel"
                    label      : "Name"
                    width      : parent.width * lv.wArr[1]
                    height     : cellHeight
                    text       : delegate && delegate.m  ? delegate.m.name : ""
                    onAccepted: rootObject.rulesChanged(target.id,target.name,getListJSON()) //function(val) { delegate.m.name = val ; }
                    onActiveFocusChanged: if(activeFocus) lv.currentIndex = index
                }
                ZTextBox {
                    id : delegate_type
                    state  : "f3-t2-nolabel"
                    label  : "Type"
                    width  : parent.width * lv.wArr[2]
                    height : cellHeight
                    text   : delegate && delegate.m  ? delegate.m.type : ""
                    onAccepted : rootObject.rulesChanged(target.id,target.name,getListJSON()) //function(val) { delegate.m.name = val ; }
                    onActiveFocusChanged: if(activeFocus) lv.currentIndex = index
                }
                ZTextBox {
                    id : delegate_choices
                    state  : "f3-t2-nolabel"
                    label  : "Choices"
                    width  : parent.width * lv.wArr[3]
                    height : cellHeight
                    text   : delegate && delegate.m  ? delegate.m.choices : ""
                    onAccepted : rootObject.rulesChanged(target.id,target.name,getListJSON()) //function(val) { delegate.m.name = val ; }
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
//                    Keys.onReturnPressed: rootObject.rulesChanged(target.id,target.name,getListJSON(index, !delegate.m.required))
//                    Keys.onEnterPressed: rootObject.rulesChanged(target.id,target.name,getListJSON(index, !delegate.m.required))

                    ZButton {
                        id : delegate_requiredBox
                        state  : delegate && delegate.m  && !delegate.m.required ? "transparent" : "success"
                        text   : ''
                        anchors.fill: parent
                        scale : 0.5
                        onClicked: {
                            var js = getListJSON(delegate._index, !delegate.m.required)
                            rootObject.rulesChanged(target.id,   target.name, js )
                        }
                            //delegate.m.required = !delegate.m.required
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

//        ZButton {
//            text   : 'Cancel'
//            state  : "danger-f2"
//            width  : parent.width/2
//            height : parent.height
//            onClicked : finish(true)
//        }
        ZButton {
            text   : 'OK'
            state  : "success-f2"
            width  : parent.width/2
            height : parent.height
            onClicked : rootObject.rulesChanged(target.id,target.name,getListJSON())
        }
    }
    QtObject{
        id : logic
        function add(){
            if(lv.model) {
                lv.model.append({name:"",type:"",choices:"",required:false })
                var js = getJSON()
//                console.log("ADD ITEM", JSON.stringify(js,null,2))
                rootObject.rulesChanged(target.id,target.name, getJSON())
            }
        }
        function del(){
            if(lv.model) {
                lv.model.remove(lv.currentIndex)
                rootObject.rulesChanged(target.id,target.name, getJSON())
            }
        }
    }
}
