//new and MORE generic, GenericHeader.
//Takes a JSON to configure!
import QtQuick 2.5

Item {
    id : rootObject
    property int status : Component.Null
    property var excludedFields: []
    property var defaultConfig : ({
                                    labelField       : 'label'  ,
                                    valueField       : 'text'   ,
                                    component        : defCmp   ,
                                    keyDisplayFunction : null  ,
                                    valueDisplayFunction : null    ,
                                    inverseValueDisplayFunction : null ,
                                    bind             : true    ,
                                    enabled          : true   ,
                                    fill              : null  ,
                                    emptyValue       : ""
                                 })
    property var configJs
    property var model
    property alias border : borderRect.border

    onModelChanged        : if(model && defaultConfig) initDelayTimer.start()
    onConfigJsChanged     : if(model && defaultConfig) initDelayTimer.start()
    onDefaultConfigChanged: if(model && defaultConfig) {
                                //correct the defaultConfig first
//                                console.log('this one')
                                if(defaultConfig.labelField === undefined)
                                    defaultConfig.labelField = 'label'
                                if(defaultConfig.valueField === undefined)
                                    defaultConfig.valueField = 'text'
                                if(defaultConfig.component === undefined)
                                    defaultConfig.component = defCmp
                                if(defaultConfig.keyDisplayFunction === undefined)
                                    defaultConfig.keyDisplayFunction = null
                                if(defaultConfig.valueDisplayFunction === undefined)
                                    defaultConfig.valueDisplayFunction = null
                                if(defaultConfig.inverseValueDisplayFunction === undefined)
                                    defaultConfig.inverseValueDisplayFunction = null
                                if(defaultConfig.bind === undefined)
                                    defaultConfig.bind = true
                                if(defaultConfig.enabled === undefined)
                                    defaultConfig.enabled = true
                                if(defaultConfig.fill === undefined)
                                    defaultConfig.fill = null
                                if(defaultConfig.emptyValue === undefined)
                                    defaultConfig.emptyValue = ""

                                initDelayTimer.start()
                            }

    property alias orientation : lv.orientation
    width  : 0
    height : 0

    QtObject {
        id : logic
        property var excludedFields: ['objectName','objectNameChanged','__']

        property ListModel lm : ListModel { id : lm ; dynamicRoles : true }

        function indexOf(arr, item, fn){
            if(!fn)
                fn = function(a,b) { return a === b }

            for(var i = 0; i < arr.length; ++i){
                if( fn(item, arr[i]) )
                    return i;
            }
            return -1;
        }

        function shallowCopy(obj) {
            var rObj = {}
            for(var o in obj)
                rObj[o] = obj[o]

            return rObj
        }
        function adjustFills(arr){
            var remainingWidth  = 1;
            var unfilledIndices = []

            for(var a in arr){
                var item = arr[a]
                var f = item.fill;
                if(f && f <= 1 && f > 0) {
                    remainingWidth -= item.fill;
                }
                else {
                    unfilledIndices.push(a)
                }
            }


            var assignFill = remainingWidth / unfilledIndices.length
            for(var u in unfilledIndices){
                item = arr[u]
                item.fill = assignFill;
            }

            //debug
//            for(a in arr){
//                item = arr[a]
//                console.log(item.key, 'fill:', item.fill)
//            }
        }
        function init(){
            console.log('init')
            status = Component.Loading

            lm.clear()

            //combine the root & logic's ALWAYS excluded fields!
            var exclusionList = rootObject.excludedFields ? rootObject.excludedFields.concat(logic.excludedFields) : logic.excludedFields
            var exList2 = ['keyDisplayFunction' , 'valueDisplayFunction', 'inverseValueDisplayFunction', "__"]
            var cmpFn = function(a,b){ return a === b || a.indexOf(b) === 0 ? true : false }

            var arr = []
//            console.log(exclusionList)
            for(var o in model){

                if(indexOf(exclusionList, o, cmpFn) === -1) {

                    var customObj  = configJs && configJs[o] ? configJs[o] : null
                    var obj        = shallowCopy(rootObject.defaultConfig)
                    obj.key       = o;

                    if(customObj){
                        for(var c in customObj) {

                            if(indexOf(exList2, c, cmpFn) !== -1)
                                continue

                            if(typeof obj[c] !== 'undefined') {
                                obj[c] = customObj[c]
                                console.log('overiding', c, 'with', customObj[c], 'in', o)
                            }
                            else {
                                if(!obj.args)
                                    obj.args = {}

                                obj.args[c] = customObj[c]
                            }
                        }
                    }

                    arr.push(obj)
                }
            }

            //adjust fills! (width or height)
            adjustFills(arr);
            lm.append(arr);

            status = Component.Ready
//            console.log("FINITO", status, status === Component.Ready)
        }


        property Timer initDelayTimer : Timer { //this can potentially save us from instantiating a bunch of times at the start!
            id : initDelayTimer
            interval : 100
            repeat : false
            running : false
            onTriggered: logic.init()
        }


    }


    ListView {
        id : lv
        property real dynamicDimension : ListView.Horizontal ? width : height

        model : logic.lm
        anchors.fill: parent
        orientation : ListView.Horizontal
        delegate : Loader {
            id : delLoader

            property int _index       : index
            property bool imADelegate : true
            property string labelField           : 'label'
            property string valueField           : 'text'
            property real   fill                 : 0
            property var    args                 : null
            property var    keyDispFunc          : null
            property var    valueDispFunc        : null
            property var    inverseValueDispFunc : null
            property bool   bind                 : false
            property string key                  : ""
            property var    emptyVal             : null
            property var    value                : emptyVal
            property var m  : lv.model.count > index ? lv.model.get(index) : null
            onMChanged : {
                var m = delLoader.m
                if(m) {
                    delLoader.valueField = m.valueField
                    delLoader.labelField = m.labelField
                    delLoader.fill       = m.fill
                    delLoader.args       = m.args
                    delLoader.bind    = m.bind
                    delLoader.key     = m.key
                    delLoader.emptyVal = m.emptyValue

                    var cfg = configJs[key]

                    delLoader.keyDispFunc   = cfg ? cfg.keyDisplayFunction : null
                    delLoader.valueDispFunc = cfg ? cfg.valueDisplayFunction : null
                    delLoader.inverseValueDispFunc = cfg ? cfg.inverseValueDisplayFunction : null

                    delLoader.value = Qt.binding(function() {
                        var v = rootObject.model[delLoader.key]
                        return v !== null && typeof v !== 'undefined' ? v : emptyVal
                    })

//                    console.log(key, valueDispFunc)

                    var component = m.component
                    if(typeof component === 'string') {
                        delLoader.source = component;
                    }
                    else if(typeof component === 'object') {
                        delLoader.sourceComponent = component;
                    }
                    else {
                        delLoader.source = ""
                        delLoader.sourceComponent = null;
                    }
//                    console.log(key, 'loading object', component)
                }
                else {
                    delLoader.labelField           ='label'
                    delLoader.valueField           ='text'
                    delLoader.fill                 =0
                    delLoader.args                 =null
                    delLoader.keyDispFunc          =null
                    delLoader.valueDispFunc        =null
                    delLoader.inverseValueDispFunc =null
                    delLoader.bind                 = false
                    delLoader.key                  = ""
                    delLoader.emptyVal             = null
                    delLoader.value                = emptyVal
                    delLoader.source = ""
                    delLoader.sourceComponent = null
                }
            }


            enabled : m ? m.enabled : false
            width  : lv.orientation === ListView.Horizontal ? lv.width  * fill : lv.width
            height : lv.orientation === ListView.Vertical   ? lv.height * fill : lv.height

            onLoaded: if(item){
                item.anchors.fill = delLoader

                if(args){   //load args onto the item, if they exist !
                    for(var a in args){
                        if(item.hasOwnProperty(a)){
                            item[a] = args[a]
                        }
                    }
                }

                if(item.hasOwnProperty(labelField)){
                    item[labelField] = typeof keyDispFunc === 'function' ? keyDispFunc(key) : key ;
                }

                if(item.hasOwnProperty(valueField)){
                    if(!bind)
                        item[valueField] = typeof valueDispFunc === 'function' ? valueDispFunc[value] : value;
                    else {
//                        if(key === 'first')
//                            console.log(typeof valueDispFunc)
                        var fn = typeof valueDispFunc === 'function' ? function() { return valueDispFunc(value) } : function() { return value }
                        item[valueField] = Qt.binding(fn);
                    }
                }
            }
        }

        Component {
            id : defCmp
            Rectangle {
                border.width: 1
//                Component.onCompleted: console.log('im created')
            }
        }
    }

    Rectangle {
        id: borderRect
        color : 'transparent'
        anchors.fill: parent
    }


}
