//Give it a ZController object (or something inherited from it) & it
//will give you the view of all the models and let you walk through them!
import QtQuick 2.5
import QtQuick.Controls 1.4


Item {
    id : rootObject
    property var   controller : null
    property real  cellHeight : 0.1
    property color color1     : 'white'
    property color color2     : 'orange'
    property font  font       : Qt.font({ pixelSize : 16 })

    onControllerChanged: if(controller){
                             logic.init()
                         }



    Connections {
        target : controller
        onNewModelAdded : if(modelName){
//            console.log("new model added", modelName, controller.models, count)
            logic.init();
        }
    }

    QtObject {
        id: logic
        property ListFunctions list     : ListFunctions   { id : fnList }
        property ObjectFunctions object : ObjectFunctions { id : fnObj  }

        property var excludeList : ['objectName', 'objectNameChanged']

        function init(){
            for(var m in controller.models){
//                console.log(m)
                if(!existsInLm(lmModels, function(i){ return i && i.name === m ? true : false })){
                    lmModels.append({name:m})
                }
            }
        }
        function existsInLm(lm, func) {
            if(lm){
                for(var i = 0; i < lm.count; ++i){
                    var item = lm.get(i)
                    if(func(item))
                        return true;
                }
            }
            return false;
        }

    }


    SplitView {
        id : sv
        anchors.fill: parent

        Item {
            id : models
            width : parent.width * 0.15
            height : parent.height

            ScrollView {
                anchors.fill: parent
                ListView {
                    id : lv
                    anchors.fill: parent
                    model : ListModel {
                        id : lmModels
                        dynamicRoles : true
                    }
                    property string currentName : model.count > 0 && currentIndex !== -1  && currentIndex < model.count ? model.get(currentIndex).name : ""


                    header : SimpleButton {
                        text : controller ? "models (" + controller.modelCount + ")" : ""
                        width : lv.width
                        height: lv.height * cellHeight
                        font : rootObject.font
                        enabled : false
                    }
                    delegate: SimpleButton {
                        width : lv.width
                        height: lv.height * cellHeight
                        color    : lv.currentIndex === index ? color2 : color1
                        font : rootObject.font
                        onClicked : lv.currentIndex = index;
                        text : name
                    }
                }
            }
        }

        Item {
            id : item
            width : parent.width * 0.15
            height: parent.height

            ScrollView {
                anchors.fill: parent
//                contentItem : lv2

                ListView {
                    id : lv2
                    anchors.fill: parent
                    model : controller.getModel(lv.currentName)
                    property var currentModelItem: model && model.count > 0 && currentIndex !== -1  && currentIndex < model.count ? model.get(currentIndex) : null
                    header : SimpleButton {
                        text    : lv.currentName + "(" +  (lv2.model ? lv2.model.count : "0") + ")"
                        width   : lv2.width
                        height  : lv2.height * cellHeight
                        font    : rootObject.font
                        enabled : false
                    }
                    delegate : SimpleButton {
                        property var m: lv2.model && lv2.model.count> index ? lv2.model.get(index) : null
                        width : lv2.width
                        height: lv2.height * cellHeight
                        color    : lv2.currentIndex === index ? color2 : color1
                        font : rootObject.font
                        onClicked : lv2.currentIndex = index;
                        text : m ? id + " (" + fnObj.getProperties(m,logic.excludeList,"__").length + " properties)": id
                    }
                }
            }
        }

        Item {
            id : itemDetail
            width : parent.width * 0.7
            height : parent.height

            ObjectBrowser {
                anchors.fill: parent
                obj : lv2.currentModelItem
                objectName: lv2.currentModelItem ? lv.currentName + "_" + lv2.currentModelItem.id : ""
                font : rootObject.font
            }

        }

    }


}



