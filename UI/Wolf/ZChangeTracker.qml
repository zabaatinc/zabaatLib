import QtQuick 2.4
import Zabaat.Misc.Global 1.0

Item
{
    id : rootObject

    property alias  __tracer            : visualItem
    property alias colorLocalChange     : visualItem.changeLocalClr
    property alias colorExternalChange  : visualItem.changeExternalClr
    property alias iconLocalChange      : visualItem.changeLocalIcon
    property alias iconExternalChange   : visualItem.changeExternalIcon
    property alias state                : visualItem.state


    property var    __trackObj          : parent ? parent : null
    property var    __model             : null;
    property var    __snapshot          : null;
    property var    __dispFunc          : null;
    property string __fieldName         : '';
    property string __valueField        : '';
    property int    __arrayIndex        : -1;
    property bool   __requested         : false;
    property var    __message           : null

    property var    __val               : privates.val()
    property var    __snappy            : privates.snapVal()

    QtObject{
        id : privates

        function val() {
            if(__model)
            {
                if(__arrayIndex === -1 && typeof __model[__fieldName] !== 'undefined')                          return __model[__fieldName]
                else if(typeof __model[__arrayIndex]       !== 'undefined' &&
                        typeof __model[__arrayIndex].value !== 'undefined' )                                    return __model[__arrayIndex].value
            }
            else if(__trackObj && typeof __trackObj.defaultVal !== 'undefined')                 return __trackObj.defaultVal;
            return                                                                              undefined
        }
        function snapVal(){
            if(__snapshot)
            {
                if(__arrayIndex === -1 && !ZGlobal._.isUndefined(__snapshot[__fieldName]))               return __snapshot[__fieldName]
                else if(typeof __snapshot[__arrayIndex]       !== 'undefined' &&
                        typeof __snapshot[__arrayIndex].value !== 'undefined' )                         return __snapshot[__arrayIndex].value
            }
            else if(__trackObj && typeof __trackObj.defaultVal !== 'undefined')                 return __trackObj.defaultVal;
            return                                                                              undefined
        }
    }




    Item{
        id : visualItem
        anchors.fill : parent

        property string changeLocalIcon    : "\uf111";
        property string changeExternalIcon : "\uf12a";
        property color  changeLocalClr     : "yellow";
        property color  changeExternalClr  : ZGlobal.style.danger;

        property var currentVal : __dispFunc                ?  __dispFunc(__val)                    : __val
        property var initialVal : __dispFunc                ?  __dispFunc(__snappy)                 : __snappy
        property var activeVal  : __dispFunc && __trackObj  ?  __dispFunc(__trackObj[__valueField]) : __trackObj[__valueField]

        state: currentVal != initialVal ?   ('changeExternal') : (currentVal != activeVal  ? 'changeLocal' : '')
//        onStateChanged: console.log(__fieldName, state, currentVal, initialVal, activeVal)

        onCurrentValChanged: {
            if(__requested)                resetVals()
            else if(state === '')          resetVals()
        }


        function resetVals(snapshot, value){
            if(snapshot === null || typeof snapshot === 'undefined')    snapshot = true
            if(value === null    || typeof value    === 'undefined')    value    = true

            if(snapshot && __snapshot)                                  __snapshot[__fieldName]     = __model[__fieldName]
            if(value    && __trackObj.hasOwnProperty(__valueField))     __trackObj[__valueField]    = __model[__fieldName]

            rebind(snapshot, value)
        }
        function rebind(snapshot, value){
            if(snapshot === null || typeof snapshot === 'undefined')    snapshot = true
            if(value === null    || typeof value    === 'undefined')    value    = true

            if(snapshot)   __snappy = Qt.binding(function() { return privates.snapVal() } )
            if(value)     activeVal  = Qt.binding(function(){ return ZGlobal.functions.isUndef(__trackObj) ? __valueField : __dispFunc ? __dispFunc(__trackObj[__valueField]) : __trackObj[__valueField]
                                                            })
        }

        Text{
            id : texty
            anchors.top     : parent.top
            anchors.right   : parent.right
            font.family     : "FontAwesome"
            font.pointSize  : ZGlobal.style.text.normal.pointSize
            font.bold       : ZGlobal.style.text.normal.bold
            font.italic     : ZGlobal.style.text.normal.italic
            text            : visualItem.state === 'changeLocal' ? visualItem.changeLocalIcon : visualItem.changeExternalIcon
            visible         : visualItem.state != ""
            color           : visualItem.state === 'changeLocal' ? visualItem.changeLocalClr : visualItem.changeExternalClr
        }

//        ZTracer{ id : tracer; color : texty.color}

        MouseArea{
            anchors.centerIn: texty
            width           : texty.paintedWidth
            height          : texty.paintedHeight
            hoverEnabled    : true
            onEntered       : if(__message && visualItem.state !== "")     __message(visualItem.currentVal)
            onExited        : if(__message)                                __message("")
        }


        states :
        [
            State { name : ""              ; PropertyChanges {} },
            State { name : "changeLocal"   ; PropertyChanges {} },
            State { name : "changeExternal"; PropertyChanges {} }
        ]


    }



}



