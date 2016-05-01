import QtQuick 2.4
import "../"
import Zabaat.Misc.Global 1.0

Item {
    id : rootObject

    property double listRatio : 0.15
    property alias model      : lv.model
    property string rootPath  : ""
    property bool rootPathCanBeBlank : false
    property color color : Qt.darker(ZGlobal.style._default)

    ZTracer {
        anchors.fill: null
        width       : rootObject.width
        height      : rootObject.height - lv.height
        borderWidth : 3
        color       : "black"
        bgColor     : rootObject.color

        Image {
            id     : bigView
            width  : parent.width  * 0.95
            height : parent.height * 0.95
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
        }
    }
    ZTracer {
        color : "black"
        borderWidth: 3
        bgColor: Qt.lighter(rootObject.color)
        width      : rootObject.width
        height     : rootObject.height * listRatio
        anchors.bottom: parent.bottom
        anchors.fill: null
        ListView {
            id         : lv
            anchors.fill: parent
            orientation: ListView.Horizontal
            spacing    : 5


            property string modelType : ""
            onCurrentIndexChanged : if(model ){
                                        if(rootPathCanBeBlank || rootPath !== ""){
                                            bigView.source = modelType === 'array' ? rootPath + model[currentIndex] :
                                                                                     rootPath + model.get(currentIndex)
                                        }
                                    }
            onModelChanged : {
                if(ZGlobal.functions.isUndef(model)) bigView.source = ""
                else               modelType = ZGlobal.functions.getType(model)
            }
            delegate: Image{
                property bool imADelegate : true
                property int  _index      : index
                width   : lv.height
                height  : width
                source  : rootPathCanBeBlank || rootObject.rootPath !== "" ? rootObject.rootPath + modelData : ""

                MouseArea{
                    anchors.fill: parent
                    onClicked   : lv.currentIndex = parent._index
                }

                Component.onCompleted: {
                    if(lv.modelType === "")
                        lv.modelType = ZGlobal.functions.getType(lv.model)
                }
            }


        }



    }



}
