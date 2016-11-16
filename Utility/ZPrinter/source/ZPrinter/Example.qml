import QtQuick 2.5
import QtQuick.Window 2.2
import Zabaat.Utility.ZPrinter 1.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
Window {
    visible: true
    width  : 640
    height : 480

    ListView {
        id : pageSizes
        width : parent.width/8
        height : parent.height
        property var availablePrinters : zprinter.supportedPageSizes
        property var apModel : []
        onAvailablePrintersChanged: {
            alm.clear()
            for(var a in availablePrinters)
                alm.append({name:availablePrinters[a]})
        }
        delegate : Button {
            text : name
            width : pageSizes.width
            onClicked : zprinter.print(ti.text, name)
        }
        model : ListModel {
            id : alm
        }
    }

    Item {
        id : theRest
        width : parent.width - parent.width/4
        height : parent.height
        anchors.right: parent.right
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
                    "supportedResolutions    :" + zprinter.supportedResolutions       + "\n" +
                    "supportsCustomPageSizes :" + zprinter.supportsCustomPageSizes    + "\n" +
                    "Enter text to try printing"
        }
        ListView {
            width : parent.width/4
            height : parent.height
            anchors.right: parent.right

            property var availablePrinters : zprinter.availablePrinters();
            property var apModel : []
            onAvailablePrintersChanged: {
                lm.clear()
                for(var a in availablePrinters)
                    lm.append({name:availablePrinters[a]})
            }
            delegate : Button {
                text : name
                onClicked : zprinter.activePrinter = text
            }
            model : ListModel {
                id : lm
            }
        }





        Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: btn.height
            width : parent.width   - btn.height
            height : parent.height - infoText.paintedHeight - btn.height
            border.width : 1
            TextArea {
                id: ti
                text: qsTr("Hello World")
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: height * 1/10
            }
        }

        Button{
            id: btnImageData
            width : 300
            text : "print Text as img (AUTO DETECT)"
            anchors.bottom: parent.bottom
            anchors.right: btnSvgImage.left;
            onClicked : {
                zprinter.printImageData(ti.text);
            }
        }
        Button{
            id: btnSvgImage
            width : 250
            text : "print Text as SVG"
            anchors.bottom: parent.bottom
            anchors.right: btnImg.left;
            onClicked : {
                zprinter.printImageData(ti.text, "svg");
            }
        }
        Button{
            id: btnImg
            text : "print image"
            anchors.bottom: parent.bottom
            anchors.right: btn.left;
            onClicked : fd.open();
        }
        Button{
            id: btn
            text : "print"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            onClicked: zprinter.print(ti.text);
        }


    }




    ZPrinter{
        id : zprinter
    }

    FileDialog {
        id : fd
        nameFilters: ["*.png","*.jpg","*.gif","*.svg","*.bmp"]
        onAccepted: {
            var f = fileUrl;
            console.log(f);
            zprinter.printImage(f, 2,2);
        }
    }
}
