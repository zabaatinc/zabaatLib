import QtQuick 2.4
import Zabaat.Material 1.0
ZSkin {
    id : rootObject
    color            : graphical.fill_Default
    border.color     : graphical.borderColor
    anchors.centerIn : parent
//    clip : true
//    border.width     : 1
    property alias graphicalOverride : graphicalOverride
    property alias font : text.font
    property alias gui  : gui
    readonly property alias isFocused : input.activeFocus

    skinFunc : function(name, params) { //the logic may call this!!
        var fn = guiLogic[name]
        if(typeof fn === 'function')
            return fn(params);
        console.log(rootObject, 'has no skin function called', name)
        return null;
    }

    QtObject  {
        id : guiLogic
        function copy()             { return input[arguments.callee.name]() }
        function cut()              { return input[arguments.callee.name]() }
        function deselect()         { return input[arguments.callee.name]() }
        function undo()             { return input[arguments.callee.name]() }
        function redo()             { return input[arguments.callee.name]() }
        function paste()            { return input[arguments.callee.name]() }
        function select(obj) {
            if(obj && obj.start !== undefined && obj.end !== undefined) {
                return input.select(obj.start, obj.end)
            }
            return null;
        }
        function selectAll()  { return input.selectAll()  }
        function selectWord(obj) {
            if(obj && typeof obj.num !== "undefined") {
                var arr = input.text.split(" ")
                var startAt = 0;
                for(var i = 0; i < arr.length && i <= obj.num; i++) {
                    var word = arr[i]
                    if(typeof word === "undefined" || word === "") {
                        obj.num++
                    }
                    else if(i !== obj.num){
                        startAt += word.length
                    }
                    else if(i === obj.num ) {
                        return input.select(startAt, startAt + word.length)
                    }
                    startAt++
                }
                return null;
            }
            return input.selectWord()
        }
        function selectedText() { return input.selectedText }
        function removeWord(obj) {
            if(obj && typeof obj.num !== "undefined") {
                var arr = input.text.split(" ")
                var startAt = 0;
                for(var i = 0; i < arr.length && i <= obj.num; i++) {
                    var word = arr[i]
                    if(typeof word === "undefined" || word === "") {
                        obj.num++
                    }
                    else if(i !== obj.num){
                        startAt += word.length
                    }
                    else if(i === obj.num ) {
                        //rempve the space before the word toO!
                        return startAt !== 0 ? input.remove(startAt - 1, startAt + word.length) :
                                               input.remove(startAt, startAt + word.length)
                    }
                    startAt++
                }
            }
            return null;
        }
    }

    QtObject {
        id : graphicalOverride
        property real  barHeight     : 4
        property int label_hAlignment : Text.AlignHCenter
        property int label_vAlignment : Text.AlignVCenter
    }

    Item {
        id: gui
        anchors.fill: parent
        property bool inputState : input.activeFocus    //when user is inputting stuff!
        property alias textArea : textArea
        focus : false

        Item {
            id : textArea
            width  : botBar.width  - 5
            property bool emptyBackground :Qt.colorEqual(rootObject.color,graphical.fill_Empty)
            property bool centerCondition : emptyBackground && label.font.pixelSize < Math.floor(rootObject.height)
            property real h               : parent.height - botBar.height
            height          : centerCondition ? h - label.font.pixelSize : h
            anchors.centerIn: centerCondition ? undefined : parent
            anchors.bottom  : centerCondition ? botBar.top : undefined
            focus : false

            property alias text : text
            property alias label : label
            property alias input : input
            Text {
                id : text
                horizontalAlignment: graphical.text_hAlignment
                verticalAlignment  : graphical.text_vAlignment
                text               : logic && logic.text ? logic.text : ""
                anchors.fill       : parent
                visible            : input.opacity === 0
                color              : input.color
                focus              : false
                onTextChanged      : input.text = text
                enabled            : false
//                echoMode: !graphicalOverride.pw ? TextInput.Normal : TextInput.Password
            }

            Item {
                anchors.fill: parent
                clip : label.clip
                Text {
                    id : label
                    verticalAlignment  : graphicalOverride.label_vAlignment
                    horizontalAlignment: graphicalOverride.label_hAlignment
                    color              : input.color
                    opacity            : 0.5    //the 0.5 opacity will give it a faded look!
                    text               : logic && logic.label ? logic.label : ""
                    font {
                        family : text.font.family
                        pixelSize: text.font.pixelSize
                    }
                    width  : parent.width
                    height : parent.height
                    anchors.left      : parent.left
                    anchors.top       : parent.top
                    anchors.topMargin : gui.inputState || (text.text !== "" && input.text !== "") ? -(height + font.pixelSize/2) : 0
                    textFormat : Text.RichText

                    Behavior on anchors.topMargin  { NumberAnimation { duration : 333  } }

                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked   : {
                    input.text = text.text
                    input.forceActiveFocus();
                }
                focus : false
            }

            TextInput {
                id                 : input
                anchors.fill       : parent
                onAccepted         : if(logic && logic.setTextFunc && insync) {
                                         logic.setTextFunc(input.text , true);
//                                         nextItemInFocusChain();
                                     }
//                echoMode: !graphicalOverride.pw ? TextInput.Normal : TextInput.Password
                onActiveFocusChanged : {
                    if(activeFocus && logic){
                        input.text = logic.text
                        insync = true;
                    }
                    else if(!activeFocus){
//                        input.text = Qt.binding(function() { return logic ? logic.text : "" })
                        insync = false;
                    }
                }

                Keys.onTabPressed: { logic.setTextFunc(input.text) ; event.accepted = false }
                onTextChanged      : if(logic && logic.setTextFunc && insync && gui.inputState)
                                         logic.setTextFunc(input.text);

                horizontalAlignment: graphical.text_hAlignment
                verticalAlignment  : graphical.text_vAlignment
                focus              : true
                opacity            : gui.inputState ? 1 : 0
                font               : text.font
                color              : graphical.text_Default
                activeFocusOnTab   : true
                text : logic ? logic.text : ""
                property bool insync : false
            }
        }


        Rectangle {
            id : botBar
            width         : parent.width * 0.95
            height        : graphicalOverride.barHeight
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: height/2
            color         : Colors.getContrastingColor(thickerBar.color,1.2)
            focus : false

            Rectangle {
                id : thickerBar
                width : parent.width
                height : parent.height + 3      //the plus should be an odd number :)

                anchors.verticalCenter: parent.verticalCenter
                color : error.text === "" ?  graphical.fill_Focus : Colors.danger
                transform: Scale {
                    yScale : 1
                    xScale : !gui.inputState ? 0  : 1
                    Behavior on xScale{ NumberAnimation { duration : 333}}
                    origin.x : parent.width/2
                }
                focus : false
            }
            Text {
                id : error
                verticalAlignment  : Text.AlignTop
                horizontalAlignment: graphical.text_hAlignment
                color              : Colors.danger
                text               : logic && logic.error ? logic.error : ""
                font               : label.font
                width              : parent.width
                height             : parent.height * 1/2
                anchors.left       : parent.left
                anchors.top        : parent.bottom
                focus : false
//                anchors.topMargin  : height * 2
            }

        }
    }

    states : ({
          "default" : { "rootObject": { "border.width" : 0,
                                      "radius"         : 0,
                                      "@width"         : [parent,"width"],
                                      "@height"        : [parent,"height"],
                                       rotation        : 0
                                      } ,
                        graphical : { "fill_Default" : "transparent" } ,
                        "graphicalOverride" : {
                          "barHeight" : 4,
                          label_hAlignment : Text.AlignHCenter,
                          label_vAlignment : Text.AlignVCenter
                         },
                       "gui.textArea.label" : { visible : true , clip : false }
          },
         "nolabel" : { "gui.textArea.label" : { visible : false }

                     } ,
         "cliplabel" : { "gui.textArea.label" : { clip : true }

                      } ,
         "nobar"    : { "graphicalOverride" : { barHeight : 0 } } ,
         "lcenter"      :{ "graphicalOverride" : { label_hAlignment : Text.AlignHCenter, label_vAlignment : Text.AlignVCenter }} ,
         "lright"       :{ "graphicalOverride" : { label_hAlignment : Text.AlignRight  , label_vAlignment : Text.AlignVCenter }} ,
         "lleft"        :{ "graphicalOverride" : { label_hAlignment : Text.AlignLeft   , label_vAlignment : Text.AlignVCenter }} ,
         "lcenterright" :{ "graphicalOverride" : { label_hAlignment : Text.AlignRight  , label_vAlignment : Text.AlignVCenter }} ,
         "lcenterleft"  :{ "graphicalOverride" : { label_hAlignment : Text.AlignLeft   , label_vAlignment : Text.AlignVCenter }} ,
         "ltop"         :{ "graphicalOverride" : { label_hAlignment : Text.AlignHCenter, label_vAlignment : Text.AlignTop     }} ,
         "ltopcenter"   :{ "graphicalOverride" : { label_hAlignment : Text.AlignHCenter, label_vAlignment : Text.AlignTop     }} ,
         "ltopright"    :{ "graphicalOverride" : { label_hAlignment : Text.AlignRight  , label_vAlignment : Text.AlignTop     }} ,
         "ltopleft"     :{ "graphicalOverride" : { label_hAlignment : Text.AlignLeft   , label_vAlignment : Text.AlignTop     }} ,
         "lbottom"      :{ "graphicalOverride" : { label_hAlignment : Text.AlignHCenter, label_vAlignment : Text.AlignBottom  }} ,
         "lbottomcenter":{ "graphicalOverride" : { label_hAlignment : Text.AlignHCenter, label_vAlignment : Text.AlignBottom  }} ,
         "lbottomright" :{ "graphicalOverride" : { label_hAlignment : Text.AlignRight  , label_vAlignment : Text.AlignBottom  }} ,
         "lbottomleft"  :{ "graphicalOverride" : { label_hAlignment : Text.AlignLeft   , label_vAlignment : Text.AlignBottom  }}

    })

}
