import QtQuick 2.4
import QtGraphicalEffects 1.0
import Zabaat.Misc.Global 1.0

Rectangle{
    id:rootObj
    property var self : this
    border.width: focus ? 1 : 0

    //functional
    signal click(bool checked, string label, var thisObj)
    property alias label: label
    property alias labelName : label.text
    property int size : 32  //optional - this dynamically sizes EVERYTHING!
    property bool isRadioButton: false  //radio button mode changes icon to a circle and prevents the item from getting unchecked
    property bool checked : false

    Keys.onEnterPressed : if(enabled && visible) mouseArea.clickFunc()
    Keys.onReturnPressed: if(enabled && visible) mouseArea.clickFunc()
    Keys.onSpacePressed : if(enabled && visible) mouseArea.clickFunc()


    onIsRadioButtonChanged: {
        if (isRadioButton){
            _unCheckedUnicodeChar = '\uf10c'
            _checkedUnicodeChar = '\uf111'
        }
    }

    //decorative
    property color textColor: 'black'
    onEnabledChanged:{
        if (enabled){
            _textColor = textColor
        }else
            _textColor = 'grey'
    }

    property color _textColor: enabled ? textColor : 'grey'


    //internal
    property string _unCheckedUnicodeChar : '\uf096'
    property string _checkedUnicodeChar   : '\uf046'
//    height:size
//    width: size + label.paintedWidth + 10
    color: 'transparent' //do not change ideally



    //deprecated
    //property alias font : box.font   // DO NOT USE - use size instead



    Text{
        id: box
        anchors.left      : parent.left
        anchors.leftMargin: 3
        font.pixelSize: rootObj.size
        font.family:"FontAwesome"
        font.bold: true
        text: _unCheckedUnicodeChar
        color: _textColor
//        font.pointSize: rootObj.size

        width  : labelName.length > 0 ? parent.width * 0.2 : parent.width
        height : parent.height

        transform: Scale{
            id : boxTrans

            origin.x : box.width/2
            origin.y : box.height/2

            property real _xScl : box.paintedWidth  > box.width ? box.width / box.paintedWidth     : 1
            property real _yScl : box.paintedHeight > box.height ? box.height / box.paintedHeight  : 1

            xScale: Math.min(_xScl,_yScl)
            yScale: xScale
        }
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Text{
        id: checkmark

        anchors.left      : parent.left
        anchors.leftMargin: 3
        font.family:"FontAwesome"
        font.bold: true
        text: _checkedUnicodeChar
        color: _textColor
//        font.pointSize: 32
        font.pixelSize: rootObj.size
        scale : 0

        width : labelName.length > 0 ? parent.width * 0.2 : parent.width
        height : parent.height

        transform: Scale{
            origin.x : checkmark.width/2
            origin.y : checkmark.height/2
            xScale : boxTrans.xScale
            yScale : boxTrans.yScale
        }

        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

//        scale : paintedWidth > width ?  width / paintedWidth : 1
    }

    Text{
        id:label
        font.pointSize         : rootObj.size / 1.6
        width                  : parent.width * 0.8 - ( box.width * 1/3)
        height                 : parent.height

        transform: Scale{
             origin.x : label.width/2
             origin.y : label.height/2

            property real _xScl : label.paintedWidth > label.width ? label.width / label.paintedWidth      : 1
            property real _yScl : label.paintedHeight > label.height ? label.height / label.paintedHeight  : 1

            xScale: Math.min(_xScl,_yScl)
            yScale: xScale
        }
        verticalAlignment      : Text.AlignVCenter

        anchors.verticalCenter : parent.verticalCenter
        anchors.left           : parent.left
        anchors.leftMargin     : box.width + box.width * 1/3
        text:'label'
        font.family:'FontAwesome'

//        scale : paintedWidth > width ?  width / paintedWidth : 1
    }

    states:[
        State{
            name:'checked';
            PropertyChanges { target: checkmark; scale :1;       }
            PropertyChanges { target : rootObj;  checked : true; }

        },
        State{
            name:'';
            PropertyChanges { target: checkmark; scale :0;       }
            PropertyChanges { target : rootObj;  checked : false; }
        }

    ]
    transitions: [
        Transition {
            from: "*"
            to: "*"
            NumberAnimation {
                target: checkmark
                property:'scale'
                duration: 400
                easing.type: Easing.OutBounce  //TODO - probably better as InOutQuad
            }
        }

    ]

    MouseArea{
        id : mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: if(rootObj.enabled){
                        label.font.underline=true
                   }

        onExited: if(rootObj.enabled) {
                    label.font.underline=false
                  }

        onClicked:clickFunc()

        function clickFunc(){
            if (rootObj.state == 'checked' && !isRadioButton)
            {
                rootObj.state = ''
                click(false, label.text, rootObj)
            }
            else
            {
                rootObj.state='checked'
                click(true, label.text, rootObj)
            }
        }
    }
//    Component.onCompleted: rootObj.state='normal'
}

