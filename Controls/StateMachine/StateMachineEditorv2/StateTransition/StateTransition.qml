import QtQuick 2.4
import Zabaat.Material 1.0
import "../Functions"
Rectangle {
    id : rootObject
    property string name            : ""
    property var origin             : null
    property var destination        : null
    property var rules              : []

//    onRulesChanged: console.log(JSON.stringify(rules,null,2))

    property string originName      : origin      ? origin.name      : ""
    property string destinationName : destination ? destination.name : ""
    property alias anim : colorAnim

    signal rightClicked(var self, int x, int y);

    function getJSON(){
        return { name : name, rules : GFuncs.toArray(rules) , state: destinationName }
    }



    height         : 4
    transformOrigin: Item.Left
    color          : Colors.text1


    QtObject {
        id : logic
        property bool loaded : false
        property int  mode   : origin ? origin.mode : 0


        property Connections con : Connections {
            target : origin ? origin : null
            onXChanged : logic.runUpdate()
            onYChanged : logic.runUpdate()
            onTransitionsUpdated : logic.runUpdate()
        }
        property Connections con2 : Connections {
            target : destination ? destination : null
            onXChanged : logic.runUpdate()
            onYChanged : logic.runUpdate()
        }

        function changeState(){
//            console.log("CHANGE STETE CALLED")
            if(!loaded){
                if(origin && destination){
//                    console.log("OH MAN!")
//                    origin.transitionsUpdated()
                    destination.transitionsUpdated("new in")
                    loaded = true;
                    runUpdate()
                }

            }
            else {
                if(!origin || !destination){
                    //we were loaded and now we are missing something!! KILL THIS!!!
//                    rootObject.destroy()
                }
            }
        }
        function runUpdate(){
            if(!origin || !destination) { //OOS
                return;
            }

            var pt1   = Qt.point(origin.x      , origin.y      )
            var pt2   = Qt.point(destination.x , destination.y )

            var a1 = Qt.point(pt1.x + origin.width/2     , pt1.y + origin.height/2)
            var a2 = Qt.point(pt2.x + destination.width/2, pt2.y + destination.height/2)

            var index     = getIndex(origin)
            var destIndex = getIndex(destination,'destination')


            var total     = origin.transitionsView ? origin.transitionsView.count : 0
            var multi     = total === 1 ? destIndex === -1 ? 0.5 :
                                                             0
                                        : index / (total-1)   //since indexes are 0 based
//            console.log("Running update", pt1, "->", pt2, index, destIndex, total)

            //lets find out if the destination has a transiution back. if it does, then we should change the multi
            if(destIndex !== -1) {
                multi /= 2;
            }

            var imulti = 1 - multi          //use this for opposite side
            var angle = getAngle(a1,a2) //got angle to the center
//            console.log(index, total, multi, imulti)

            if(angle >= -45 && angle <= 45){    //arrow rightCenter
//                console.log("1")
                rootObject.x = origin.width
                rootObject.y = origin.height  * multi

                pt2.y += destination.height * multi
            }
            else if(angle < -45 && angle >= -135) {  //arrow topCenter
//                console.log("2")
                rootObject.x = origin.width * multi;
                rootObject.y = 0;

                pt2.y += destination.height
                pt2.x += destination.width * multi
            }
            else if(angle <= 135 && angle > 45){    //arrow bottomcenter
//                console.log("3")
                pt2.x += destination.width * imulti

                rootObject.y = origin.height
                rootObject.x = origin.width * imulti
            }
            else {                                  //arrow leftcenter
//                console.log("4")
                pt2.y += destination.height * imulti
                pt2.x += destination.width

                rootObject.x = 0;
                rootObject.y = origin.height * imulti
            }

            pt1.y += rootObject.y
            pt1.x += rootObject.x

            rootObject.width    = getDistance(pt1, pt2)
            rootObject.rotation = getAngle(pt1,pt2)
        }


        function getIndex(target, prop){
            if(target && target.logic.transitions && target.transitionsView){
//                console.log("TRAGET HAS IT ALl" , target.logic.transitions, target.transitionsView)
                for(var i =0 ; i < target.logic.transitions.count; ++i){
                    var item = target.transitionsView.itemAt(i)
                    if(item){
                        if(prop === null || typeof prop === 'undefined')
                        {
                            if(item === rootObject)
                                return i;
                        }
                        else if(item.destination && rootObject.origin && rootObject.origin === item.destination){
                            return i
                        }
                    }
                }
            }
            return -1;
        }


        function getDistance(pt1,pt2){
//            console.log("getDistance", pt1,pt2)
            return Math.sqrt( Math.pow(pt2.x - pt1.x ,2) + Math.pow(pt2.y - pt1.y,2)  )
        }
        function getAngle(pt1, pt2){   //with respenct to xAxis as being 0
            return ((Math.atan2(pt2.y - pt1.y, pt2.x - pt1.x)) * 180/Math.PI)
        }
    }


    ArrowHead{
        height : parent.height
        width  : height * 4
        anchors.right: parent.right
        rotation : 90
        color : parent.color
    }

    onOriginChanged     : logic.changeState()
    onDestinationChanged: logic.changeState()

    MouseArea {
        width           : parent.width
        height          : parent.height
        anchors.centerIn: parent
        acceptedButtons : Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onClicked       : rootObject.rightClicked(rootObject,mouseX,mouseY)
        onDoubleClicked : rootObject.rightClicked(rootObject,mouseX,mouseY)
        onEntered : rootObject.color = Colors.warning
        onExited  : rootObject.color = Colors.text1
    }
    Text {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        font.family: Fonts.font1
        font.pixelSize: parent.height * 5
        anchors.bottom: parent.top
        text : parent.name
//        rotation : -parent.rotation
    }


    Rectangle {
        //for ease of use in grabbing for overlapping ARROWS!!
        radius : height/2
        width : height
        height : rootObject.height * 4
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: rootObject.width < 30 ? rootObject.width * 0.2 : 30
        border.width: 2
        border.color: rootObject.color
        color : Colors.standard
        MouseArea {
            acceptedButtons : Qt.RightButton | Qt.LeftButton
            hoverEnabled: true
            onClicked       : rootObject.rightClicked(rootObject,mouseX,mouseY)
            onDoubleClicked : rootObject.rightClicked(rootObject,mouseX,mouseY)
            onEntered : rootObject.color = Colors.warning
            onExited  : rootObject.color = Colors.text1
            anchors.fill: parent
        }
    }


    SequentialAnimation on color {
        id    : colorAnim
        loops : Animation.Infinite
        running : false
        ColorAnimation {
            from    : Colors.text1
            to      : Colors.text2
            duration: 333
        }
        ColorAnimation {
            to      : Colors.text1
            from    : Colors.text2
            duration: 333
        }
        onStopped: rootObject.color = Colors.text1
    }

}
