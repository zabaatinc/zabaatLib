import QtQuick 2.5
import QtQuick.Window 2.2
import Zabaat.Utility.ZPrinter 1.0
import QtQuick.Controls 1.4

Window {
    visible: true
    width  : 640
    height : 480

    Text{
        id: infoText
        font.family: "Courier"
        font.pixelSize: parent.height * 1/40
        text :  "activePrinter           :" + zprinter.activePrinter              + "\n" +
                "makeAndModel            :" + zprinter.makeAndModel               + "\n" +
                "description             :" + zprinter.description                + "\n" +
                "defaultDuplexMode       :" + zprinter.defaultDuplexMode          + "\n" +
                "defaultPageSize         :" + zprinter.defaultPageSize            + "\n" +
                "isDefault               :" + zprinter.isDefault                  + "\n" +
                "isNull                  :" + zprinter.isNull                     + "\n" +
                "isRemote                :" + zprinter.isRemote                   + "\n" +
                "location                :" + zprinter.location                   + "\n" +
                "maximumPageSize         :" + zprinter.maximumPageSize            + "\n" +
                "minimumPageSize         :" + zprinter.minimumPageSize            + "\n" +
                "state                   :" + zprinter.state                      + "\n" +
                "supportedDuplexModes    :" + zprinter.supportedDuplexModes       + "\n" +
                "supportedPageSizes      :" + zprinter.supportedPageSizes         + "\n" +
                "supportedResolutions    :" + zprinter.supportedResolutions       + "\n" +
                "supportsCustomPageSizes :" + zprinter.supportsCustomPageSizes    + "\n" +
                "Enter text to try printing"
    }
    Text{
        id: infoText2
        font.family: "Courier"
        font.pixelSize: parent.height * 1/40
        horizontalAlignment: Text.AlignRight
        width : parent.width

        property var availablePrinters : zprinter.availablePrinters();
        property var apString : []
        onAvailablePrintersChanged: {
            var temp = ""
            for(var a in availablePrinters){
                temp += "\n" + availablePrinters[a]
            }
            apString = temp;
        }

        text :  "availablePrinters:" + apString;
    }


    Rectangle {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: btn.height
        width : parent.width   - btn.height
        height : parent.height - infoText.paintedHeight - btn.height
        border.width : 1
        TextInput {
            id: ti
            text: qsTr("Hello World")
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: height * 1/10
        }
    }


    Button{
        id: btn
        text : "print"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked: zprinter.print(ti.text);
    }



    ZPrinter{
        id : zprinter

    }
}
