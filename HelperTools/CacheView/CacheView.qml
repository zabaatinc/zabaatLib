import QtQuick 2.5
import QtQuick.Controls 1.4
import Zabaat.Utility.SubModel 1.1
Item {
    property var cachePtr : null


    QtObject {
        id : logic
        property var models : []
        property ListModel original : ListModel { id : orig }
        property ZSubModel sub      : ZSubModel { id : sub  }

        function refreshModels(){   //read nameMap
            var arr = []
            for(var c in cachePtr.nameMap){
                if(cachePtr.nameMap.indexOf("/") !== -1) {
                    arr.push(cachePtr.split("/")[0])
                }
            }
            models = arr;
        }



        function filter(text) {

        }


    }

    Item {
        id : gui
        anchors.fill: parent

        SplitView {
            id : sv
            anchors.fill: parent
            Item {
                id : left
                width : parent.width * 0.3
                height : parent.height

                ComboBox {
                    width : parent.width
                    height : parent.height * 0.1
                    model : logic.models
                    onCurrentTextChanged: logic.filter(currentText)
                }

                ListView {
                    id : lv
                    width : parent.width
                    height : parent.height * 0.9
                    model : sub
                    delegate : Rectangle {
                        width : lv.width
                        height : lv.height * 0.1
                        Text {
                            anchors.fill: parent
                            anchors.margins: 5
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text : name + "<br>" + src
                        }
                    }
                }

            }

            Image {
                id : right
                width  : parent.width - left.width
                height : parent.height
            }
        }


    }

}
