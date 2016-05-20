import QtQuick 2.4
import "zBaseComponents"
import Zabaat.Misc.Global 1.0
import Zabaat.UI.Fonts 1.0

Item {
    id : rootObject



    property alias labelName       : label.text
    property double inputAreaRatio : 0.5

    property int hrs     : 1
    property int mins    : 00
    property var time   : {
        var date = new Date()
        date.setHours(hrs,mins,0,0)
        return date
    }
//    onTimeChanged : console.log(Qt.formatTime(time), "--", hrs,":",mins)

    ZBase_Text {
        id : label
        width                   : parent.width
        height                  : text !== "" ? parent.height - timeRow2.height : 0
        showOutlines            : false
        fontColor               : ZGlobal.style.text.color2
        color                   : ZGlobal.style.accent
        border.width: 1
        text                    : "Time"
        dText {
            horizontalAlignment: Text.AlignLeft
            x : 2

        }
    }
    Row        {
        id : timeRow2
        width  : parent.width
        height : labelName !== "" ? parent.height * inputAreaRatio : parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        property var hrs       : null
        property var separator : null
        property var min1      : null
        property var min2      : null
        property var ampm      : null

        Component.onCompleted: {        //SETUPS UP THE STUFF HAR HAR BRO BRO
            hrs       = digitFactory.createObject(timeRow2)
            separator = seperatorFactory.createObject(timeRow2)
            min1      = digitFactory.createObject(timeRow2)
            min2      = digitFactory.createObject(timeRow2)
            ampm      = digitFactory.createObject(timeRow2)

            hrs.leftOrRight.connect(leftOrRight)
            min1.leftOrRight.connect(leftOrRight)
            min2.leftOrRight.connect(leftOrRight)
            ampm.leftOrRight.connect(leftOrRight)


            ampm.numMatching = false
            hrs.searchLen = 2

            separator.wPerc                     = 0.05       //0.05
            hrs.wPerc                           = 0.7 / 2
            min1.wPerc = min2.wPerc             = hrs.wPerc/2
            ampm.wPerc                          = 0.25       //0.3

            hrs .model = ['01','02','03','04','05','06','07','08','09','10','11','12']
            min1.model = ['0','1','2','3','4','5'];
            min2.model = ['0','1','2','3','4','5','6','7','8','9'];
            ampm.model = ['AM','PM']

            //setValues naoo
//            var myTime = rootObject.time
//            rootObject.time.getHours()
            var _hrs  = rootObject.time.getHours()
            var _mins = rootObject.time.getMinutes()


            if(_hrs  < 1 || _hrs  > 24)   _hrs  = 1
            if(_mins < 0 || _mins > 60)   _mins = 0

            if(_hrs > 12) {
                ampm.setValue("PM")
                hrs.setValue(_hrs - 12)
            }
            else{
                ampm.setValue("AM")
                hrs.setValue(_hrs)
            }

            var minsStr = rootObject.mins < 10 ? "0" + rootObject.mins.toString() : rootObject.mins.toString()
            min1.setValue(minsStr.charAt(0))
            min2.setValue(minsStr.charAt(1))

            //CREATE BINDINGS OHH OHH OHHH
            functions.inputHrs  = Qt.binding(function() { return hrs.value } )
            functions.inputMins1 = Qt.binding(function() { return min1.value} )
            functions.inputMins2 = Qt.binding(function() { return min2.value} )
            functions.inputAmpm  = Qt.binding(function() { return ampm.value } )
        }

        function leftOrRight(obj, event){
            if(event === 'l'){
                if(obj === ampm){
                    min2.focus = true
                    obj.focus = false
                }
                else if(obj === min2){
                    min1.focus = true
                    obj.focus = false
                }
                if(obj === min1){
                    hrs.focus = true
                    obj.focus = false
                }
            }
            else {
                if(obj === hrs){
                    min1.focus = true
                    obj.focus = false
                }
                else if(obj === min1){
                    min2.focus = true
                    obj.focus = false
                }
                if(obj === min2){
                    ampm.focus = true
                    obj.focus = false
                }
            }
        }
        function setDefaults(params){
            for(var p = 0 ; p < params.length; p++){
                var obj = params[p]
                obj.height = Qt.binding(parent.height)

                if(obj.imADigit)
                    obj.width  = Qt.binding(digitW)
//
                obj.width  = Qt.binding(digitW)

                switch(p){
                    case 0 : obj.achors.left = parent.left; break;
                    default: obj.anchors.left = params[p -1].right ; break;
                }
            }

        }
    }
    QtObject   {
        id : functions

        property var inputHrs   : null  //gets set up by Component.onCompleted
        property var inputMins1 : null  //gets set up by Component.onCompleted
        property var inputMins2 : null  //gets set up by Component.onCompleted
        property var inputAmpm  : null  //gets set up by Component.onCompleted
        onInputHrsChanged  : handleChange()
        onInputMins1Changed: handleChange()
        onInputMins2Changed: handleChange()
        onInputAmpmChanged : handleChange()

        function handleChange(){
            if(inputHrs !== null && inputMins1 !== null && inputMins2 !== null && inputAmpm !== null){
                var hours = +inputHrs
                if(inputAmpm === "AM"){
                    rootObject.hrs = hours === 12 ? 0 : hours
                }
                else {
                    rootObject.hrs = hours === 12 ? hours : hours + 12
                }
                rootObject.mins = +(inputMins1 + inputMins2)    //concat the str
            }
        }
    }
    Component  {
        id : digitFactory
        ZBase_Text {
            id : __digit
            signal unfocusOthers(var self)
            signal leftOrRight(var obj, string event)

            property double wPerc : 1.0
            width  : parent.width * wPerc
            height : parent.height
            property var model : null
            property var value : index === -1 ? null :
                                                model && ZGlobal.functions.isDef(model[index]) ? model[index] : null

            property bool numMatching : true
            property var holdingVal   : null
            property bool imADigit    : true
            property int index        : -1
            property int searchLen    : 1
            property string searchStr : ""

            text : ZGlobal.functions.isDef(value) ? value : "x_x"
            color           : focus ? ZGlobal.style.info        : ZGlobal.style._default
            fontColor       : focus ? ZGlobal.style.text.color2 : ZGlobal.style.text.color1
            border.width: 1
            activeFocusOnTab: true
            Keys.onPressed: {
                switch(event.key){
                    case Qt.Key_Up     :  up(); event.accepted = true; break;
                    case Qt.Key_Down   :  dn(); event.accepted = true; break;
                    case Qt.Key_Right  :  leftOrRight(__digit, "r"); event.accepted = true; break;
                    case Qt.Key_Left   :  leftOrRight (__digit ,"l"); event.accepted = true; break;
                    default            :  keySearch(event,event.key) ; break;
                }
            }

            function dn() {
                if(model && index - 1 >= 0 && ZGlobal.functions.isDef(model[index]) )
                    index--
            }
            function up(){
                if(model && index + 1 < model.length)
                    index++
            }
            function setValue(val){
                if(model) {
                    index = find(val)
                    holdingVal = null
                    return index
                }
                else{
                    holdingVal = val
                    return false
                }
            }
            function find(val){
                if(model){
                    val = numMatching ? +val      : val.toLowerCase()
                    for(var i = 0; i < model.length; i++){
                        var item = numMatching ? +model[i] : model[i].toLowerCase()
                        if(val == item)
                            return i
                    }
                }
                return -1
            }
            function keySearch(event, key){
                if(searchLen > 0 && (key === Qt.Key_A || key === Qt.Key_P ||(key >= Qt.Key_0 && key <= Qt.Key_9) )){
                    var val = ''
                    switch(key){
                        case Qt.Key_A: val = "AM"; event.accepted = true;  break;
                        case Qt.Key_P: val = "PM"; event.accepted = true;  break;
                        case Qt.Key_0: val = "0"; event.accepted = true;  break;
                        case Qt.Key_1: val = "1"; event.accepted = true;  break;
                        case Qt.Key_2: val = "2"; event.accepted = true;  break;
                        case Qt.Key_3: val = "3"; event.accepted = true;  break;
                        case Qt.Key_4: val = "4"; event.accepted = true;  break;
                        case Qt.Key_5: val = "5"; event.accepted = true;  break;
                        case Qt.Key_6: val = "6"; event.accepted = true;  break;
                        case Qt.Key_7: val = "7"; event.accepted = true;  break;
                        case Qt.Key_8: val = "8"; event.accepted = true;  break;
                        case Qt.Key_9: val = "9"; event.accepted = true;  break;
                    }
                    searchStr += val
                    if(searchStr.length <  searchLen)
                        searchTimer.start()
                    else {
                        searchTimer.stop()
                        doSearch(searchStr)
                        searchStr = ""
                    }
                }
            }
            function doSearch(search, itr){
                if(ZGlobal.functions.isUndef(itr))
                    itr = 0

                if(model){
                    var index = find(search)
                    if(index !== -1){
                        holdingVal       = null
                        __digit.index = index
                        return true
                    }
                    else if(search.length > 1){
                        return doSearch(search.slice(0,-1), itr + 1)
                    }
                    else
                        return false
                }
                return false
            }
            onModelChanged : if(model && holdingVal)
                                 setValue(holdingVal)

            Timer {
                id :searchTimer
                running : false
                repeat : false
                interval : 300
                onTriggered : {
                    if(__digit.doSearch(__digit.searchStr))
                        __digit.searchStr = 0
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked   : {__digit.focus = true ; unfocusOthers(__digit) }
            }
        }
    }
    Component  {
        id : seperatorFactory
        Rectangle {
            id : seperator
            property double wPerc : 1.0
            width : parent.width * wPerc
            height : parent.height

            property int dotSize: width * 0.4
            border.width: 1
            color : ZGlobal.style._default

            Rectangle {
                width : parent.dotSize
                height : width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: height
                radius : height/2
                color : ZGlobal.style.text.color1
            }
            Rectangle {
                width : parent.dotSize
                height : width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: height
                radius : height/2
                color : ZGlobal.style.text.color1
            }
        }
    }


}


