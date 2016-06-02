import QtQuick 2.4
import Zabaat.Material 1.0
ZObject{
    objectName : "ZButton"
    signal pressed(var self)
    signal clicked(var self, int x, int y, int button)
    signal doubleClicked(var self, int x , int y, int button)

    property bool containsMouse      : false
    property string text             : ""
    property bool   allowDoubleClicks: false
//    focus : true;
    debug                  : false
    onPressed              : log(self, "pressed")
    onClicked              : log(self, "clicked"      , x,  y,  button)
    onDoubleClicked        : log(self, "doubleClicked", x,  y,  button)
    onContainsMouseChanged : log(this, "containsMouse", containsMouse )


    function getUnformattedText(rtfText){   //will remove all the stuff between < && >
        if(rtfText === null || typeof rtfText === 'undefined')
            rtfText = text;

        do {
            var startIndex = rtfText.indexOf("<")
            var endIndex   = rtfText.indexOf(">")
            if(startIndex !== -1 && startIndex < endIndex )
                rtfText = rtfText.substring(0,startIndex) + rtfText.substring(endIndex+ 1, rtfText.length);
        }while(startIndex !== -1 && startIndex < endIndex )

        return rtfText;
    }

}
