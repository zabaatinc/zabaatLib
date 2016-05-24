import QtQuick 2.5
import Zabaat.Utility 1.0
Item {

    property var modelItem : ({
                                first  : "Shahan",
                                last   : "Kazi"  ,
                                age    :  28 ,
                                gender : 'Male' ,

                              })

    Text {
        text : "status: " + gh.status
    }



    GenericHeader {
        id : gh
        width : parent.width /2
        height : parent.height / 10
        model : modelItem
        anchors.centerIn: parent
        defaultConfig : ({ component : textCmp })
        configJs: ({
                       first : {
                           valueDisplayFunction : function(a) { return a.toUpperCase() }
                       }


                   })
    }


    Component {
        id: textCmp
        Text{
//            Component.onCompleted: console.log('textCmp made!')
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: height * 1/3
        }
    }



}
