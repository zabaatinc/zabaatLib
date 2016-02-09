import QtQuick 2.0
import Qt.labs.folderlistmodel 2.1
import QtQuick.Controls 1.0
import Zabaat.UI.Wolf 1.0
import Zabaat.WolfSys 1.0

Column
{
    spacing : 20
    property alias dir : flm.rootFolder
    ZButton
    {
        x : parent.width/2 - width/2
        id : createBtn
        btnText : "Create"
        onBtnClicked :  loadPage("ZPdfReportEditor.qml", [ { name : 'dataSection', value : mainDataSection() } ] )
    }

    WolfSys    {        id : sys    }

    ListView
    {
        x : parent.width/2  - width/2

        width : 500
        height : 800
        model : FolderListModel
        {
            id : flm
            showDirs : false
            showDotAndDotDot : false
            folder : "BluePrints"
            nameFilters : ["*.qml"]
        }

        delegate: Component
        {
            Row
            {
                Text
                {
                    id : txt
                    text : fileName
                    visible : false
                }

                ZTextBox
                {
                    isEnabled: false
                    text : txt.text

                    MouseArea
                    {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Qt.darker(parent.color)
                        onExited:  parent.color = Qt.lighter(parent.color)
                        onClicked:
                        {

                        }
                    }
                }

                ZButton
                {
                    btnText : "Edit"
                    onBtnClicked :  loadPage("ZPdfReportEditor.qml", [ { name : 'dataSection', value : mainDataSection() } ,
                                                                  { name : 'pdfSource'  , value : flm.folder + "/" + txt.text }
                                                                ] )
                }
            }
        }
    }



}

