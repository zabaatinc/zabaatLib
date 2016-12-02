import QtQuick 2.4
import Zabaat.Material 1.0
ZObject{
    id : rootObject
    objectName : "ZButton"
    signal pressed(var self)
    signal clicked(var self, int x, int y, int button)
    signal singleClicked(var self, int x,  int y, int button)
    signal doubleClicked(var self, int x , int y, int button)

    property int acceptedButtons : -1
    property bool containsMouse      : false
    property string text             : ""
    property bool   allowDoubleClicks: false
//    focus : true;
    debug                  : false
//    onPressed              : log(self, "pressed")
//    onClicked              : log(self, "clicked"      , x,  y,  button)
    onSingleClicked        : {
        if(!rootObject) return;
        clicked(self,x,y,button)
//        log(self, "singleClicked", x,y,button)
    }
    onDoubleClicked        : {
        if(!rootObject) return;
        clicked(self,x,y,button)
//        log(self, "doubleClicked", x,  y,  button)
    }
    onContainsMouseChanged : {
        if(!rootObject) return;
//        log(this, "containsMouse", containsMouse )
    }


    function paintedWidth() { return skinFunc(arguments.callee.name) }
    function paintedHeight() { return skinFunc(arguments.callee.name) }
    function getTextStartPos() { return skinFunc(arguments.callee.name) }
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
