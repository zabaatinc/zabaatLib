import QtQuick 2.4
import Zabaat.UI.Wolf 1.1
import Zabaat.Misc.Global 1.0

Item {
    id : rootObject
    property color fontColor      : ZGlobal.style.text.color2
    property color color          : ZGlobal.style.accent
    property color mouseAreaColor : "transparent"

    signal hovered()
    signal unHovered()
    signal clicked(var self)
    signal doubleClicked(var self)
    signal rightClicked(var self)
    signal genericSignal(var changeObj)    //use this as a way to have even more control over your components (when they need to talk back!!
                                           //All header components talk to this.

    signal focusSignal(string fieldName, var obj)
    property int alignment : Text.AlignLeft
    property bool fillWidth : true


    onAlignmentChanged: privates.setAlignment()

    property alias rowPtr   : row
    property alias advanced : adv

    property var    fields                     : []
    property var    fields_displayFuncs        : ({})
    property var    fields_inverseDisplayFuncs : ({})
    property var    fields_font                : ({})
    property var    fields_widths              : ({})
    property var    fields_labels              : ({})
    property string fields_labelPosition       : ""
    property var    fields_alignments          : ({})
    property var    self                       : this
    property var    externalInitFunc           : null   //passes in fields, delegates, model

    property bool   debugMode               : false
    property var model                      : null

    GenericHeader_AdvancedProperties{
        id : adv
    }

     property alias  msArea : msArea
    onWidthChanged : adjustWidths()
    onModelChanged : privates.init('model')
    onFieldsChanged: privates.init('model')

    function setValue(fieldName, value){
        var index = ZGlobal._.indexOf(fields,fieldName,false)
        if(index !== -1){
            var item = privates.fieldMap[fieldName]
            if(item){
                var type = ZGlobal.functions.getType(fields_displayFuncs)
                var func = type === 'array' ? fields_displayFuncs[index] : fields_displayFuncs[fieldName]
                var valField = adv.fields_valueField && adv.fields_valueField[fieldName] ? adv.fields_valueField[fieldName] : adv.valueField
                item[valField] = func ? func(value) : value
            }
        }
    }

    function reevaluateValues(){
        for(var i = 0; i < fields.length; i++){
            var f = fields[i]
            var item = privates.fieldMap[f]
            if(item){
                var valField = adv.fields_valueField   && adv.fields_valueField[f]   ? adv.fields_valueField[f]   : adv.valueField
                var dontBind = ZGlobal._.isArray(adv.fields_dontBind) && ZGlobal._.indexOf(adv.fields_dontBind, f, false) !== -1
                item[valField] = dontBind ? getValue(item) : Qt.binding(function() { return getValue(item) })
            }
        }
    }
    function reevaluateEnabled(){
        for(var i = 0; i < fields.length; i++){
            var f        = fields[i]
            var field    = privates.fieldMap[f]
            if(field){
                field.enabled    = adv.fields_enabled && ZGlobal._.isArray(adv.fields_enabled) ? ZGlobal._.indexOf(adv.fields_enabled, f, false) !== -1 : adv.itemIsEnabled
            }
        }
    }

    function filledModel(allFields){
        var obj = {}
        if(fields){
            var properties = allFields ? ZGlobal.functions.getProperties(model) : null

            for(var i = 0; i < fields.length; i++){
                var f = fields[i]
                var fieldObj = privates.fieldMap[f]
                var inverseListType = ZGlobal.functions.getType(fields_inverseDisplayFuncs)
                if(fieldObj) {
                    var fieldName = adv.fields_valueField  && adv.fields_valueField[f]   ? adv.fields_valueField[f]   : adv.valueField

                    if(inverseListType === 'array' && fields_inverseDisplayFuncs[i])
                        obj[f] = fields_inverseDisplayFuncs[i](fieldObj[fieldName], model, fieldObj)
                    else if(inverseListType === 'object' && fields_inverseDisplayFuncs[f])
                        obj[f] = fields_inverseDisplayFuncs[f](fieldObj[fieldName], model, fieldObj)
                    else
                        obj[f] = fieldObj[fieldName]
                }

                if(properties) {
                    var ind = ZGlobal._.indexOf(properties,f,false)
                    if(ind !== -1)
                        properties.splice(ind,1)
                }
            }

            if(properties ){
                for(i = 0; i < properties.length; i++){
                    var p = properties[i]
                    obj[p] = model[p]
                }
            }

        }
        return obj
    }


    /*! returns an object with input in every field! Can take an array or jsObject
        as input as well. Instead will iterate over the model fleds
    */
    function blankModel(input){
        var obj = {}
        if(fields){
            var type = ZGlobal.functions.getType(input)
            if(type === null || type === 'undefined' || type === 'null')
                input = ""
            var isArr = type === 'array'
            var isObj = type === 'object'

            for(var i = 0; i < fields.length; i++){
                var f = fields[i]

                if     (isArr && input[i])             obj[f] = input[i]
                else if(isObj && input[f])             obj[f] = input[f]
                else                                   obj[f] = input
            }
        }
//        console.log("BLANKMODEL", JSON.stringify(obj,null,2))
        return obj
    }

    function getDelegateItem(fieldName){
       if(privates.fieldMap && privates.fieldMap[fieldName]){
           return privates.fieldMap[fieldName]
       }
       return null
    }
    function adjustWidths(){
         if(fields)
         {
             var remainingWidth  = 1
             var remainingFields = ZGlobal._.clone(fields)
             var field_widthType = ZGlobal.functions.getType(fields_widths)

             for(var i = fields.length - 1; i >= 0; i--){
                 var f = fields[i]
                 var item = privates.fieldMap[f]

                 if(item){
                     if(field_widthType === 'object' && fields_widths[f]){
                            item.width = rootObject.width * fields_widths[f]
                            remainingWidth -= fields_widths[f]
                            remainingFields.splice(i,1)
                     }
                     else if(field_widthType === 'array' && fields_widths[i] ){
                         item.width = rootObject.width * fields_widths[i]
                         remainingWidth -= fields_widths[i]
                         remainingFields.splice(i,1)
                     }
                 }
             }

             if(fillWidth){
                 var newWidth = remainingWidth / remainingFields.length
//                 console.log(remainingWidth , '/', remainingFields, newWidth)
                 for(i = 0 ; i < remainingFields.length; i++){
                     f = remainingFields[i]
                     if(privates.fieldMap[f])
                         privates.fieldMap[f].width = rootObject.width * newWidth
                 }
             }
         }
    }

//    Rectangle { anchors.fill: parent; color : 'green' }

    Row{
        id : row
        height : rootObject.height
    }

    MouseArea{
        id : msArea
        width             : row.width
        height            : parent.height
        anchors.left      : parent.left
        anchors.leftMargin: rootObject.alignment !== Text.AlignHCenter ? 0 : rootObject.width > row.width ?  rootObject.width/2 - row.width/2 : row.width/2 - rootObject.width/2
//        z : 9999
        acceptedButtons : Qt.LeftButton | Qt.RightButton

        hoverEnabled: true
        onEntered : hovered()
        onExited  : unHovered()
        onClicked : {
                        if(mouse.button & Qt.LeftButton)
                        {
                            mouse.accepted = false ;
                            rootObject.clicked(rootObject)
                        }
                        if(mouse.button & Qt.RightButton){
                            mouse.accepted = false ;
                            rootObject.rightClicked(rootObject)
                        }
                     }
        onDoubleClicked: { mouse.accepted = false ; rootObject.doubleClicked(rootObject) }

        preventStealing: false
        propagateComposedEvents: true
    }

    function getValue(obj){
        if(obj && model)
        {
            var f   = obj.fieldName
            var ret =  fields_displayFuncs[f] ? fields_displayFuncs[f](model[f],model, privates.fieldMap[f]) : model[f]
            if(ret !== null && typeof ret !== 'undefined')
                return ret
        }
        return 'x_x'
    }

    QtObject{
        id : privates
        property var fieldMap : ({})

        function setAlignment(){
            if(alignment === Text.AlignLeft){
                row.anchors.horizontalCenter = undefined
                row.anchors.right            = undefined
                row.anchors.left             = rootObject.left
            }
            else if(alignment === Text.AlignRight){
                row.anchors.horizontalCenter = undefined
                row.anchors.right            = rootObject.right
                row.anchors.left             = undefined
            }
            else {
                row.anchors.horizontalCenter = rootObject.horizontalCenter
                row.anchors.right            = undefined
                row.anchors.left             = undefined
            }
        }




        function init(){
            if(debugMode) {
                console.log(rootObject, model, "INIT CALLED YAAAAARRRRrrrr", ZGlobal.functions.getType(model), fields)
            }

            if(ZGlobal.functions.isDef(model,fields)){

                ZGlobal.functions.clearChildren(row)
                for(var i = 0; i < fields.length; i++){

                    var f        = fields[i]

                    var type     = adv.fields_typeOverride && adv.fields_typeOverride[f] ? adv.fields_typeOverride[f] : adv.itemType
                    var valField = adv.fields_valueField   && adv.fields_valueField[f]   ? adv.fields_valueField[f]   : adv.valueField
                    var addtl    = adv.fields_addtlQml     && adv.fields_addtlQml[f]     ? adv.fields_addtlQml[f]     : adv.additionalItemProperties
                    var enabl    = adv.fields_enabled      && ZGlobal._.isArray(adv.fields_enabled) ? ZGlobal._.indexOf(adv.fields_enabled, f, false) !== -1 : adv.itemIsEnabled

                    var tbox    = ZGlobal.functions.getQmlObject(["QtQuick 2.4","Zabaat.UI.Wolf 1.1","Zabaat.Misc.Global 1.0","QtQuick.Controls 1.2"], type + "{
                                                                                                  signal genericSignal(var changeObj);
                                                                                                  signal focusSignal(string fieldName, var self);
                                                                                                  property string fieldName   : '';
                                                                                                  activeFocusOnTab : enabled;
                                                                                                  onFocusChanged : if(focus) focusSignal(fieldName, this);
                                                                                                  "
                                                                                                  + addtl +
                                                                                                  "}", row)
                    privates.fieldMap[f] = tbox
                    tbox.genericSignal.connect(rootObject.genericSignal)
                    tbox.focusSignal.connect(rootObject.focusSignal)
                    tbox.height     = Qt.binding(function() { return row.height })
                    tbox.enabled    = enabl


                    tbox.fieldName      = f
                    tbox.objectName     = f + i



//                    console.log("TRY CATCH ENDED")


                    if(hasAndNotIgnored(tbox,'haveLabelRect' , f))   tbox.haveLabelRect  = Qt.binding(function() { return tbox.labelName.length > 0 } )
                    if(hasAndNotIgnored(tbox,'outlineVisible', f))   tbox.outlineVisible = false
                    if(hasAndNotIgnored(tbox,'color'         , f))   tbox.color          = Qt.binding(function() { return rootObject.color     } )
                    if(hasAndNotIgnored(tbox,'fontColor'     , f))   tbox.fontColor      = Qt.binding(function() { return rootObject.fontColor } )
                    if(hasAndNotIgnored(tbox,'state'         , f))   tbox.state          = fields_labelPosition.toLowerCase()

                    var dontBind = ZGlobal._.isArray(adv.fields_dontBind) && ZGlobal._.indexOf(adv.fields_dontBind, f, false) !== -1
                    try{
                        tbox[valField] = dontBind ? getValue(tbox) : Qt.binding(function() { return getValue(this) })
//                        console.log("I TRIED HAR HAR")
                    }
                    catch(e){
//                        console.log("FAILED TO ASSIGN value to", f, "with Value field", getValue(tbox))
                    }


                    var labelsType = ZGlobal.functions.getType(fields_labels)
                    if(hasAndNotIgnored(tbox,'labelName'     , f)) {
                        if(labelsType === 'array'){
                            tbox.labelName = fields_labels[i] ? fields_labels[i] : ""
                        }
                        else if(labelsType === 'listmodel'){
                            tbox.labelName = fields_labels[f] ? fields_labels[f] : ""
                        }
                        else
                            tbox.labelName = ""
                    }



                    if(fields_alignments && fields_alignments[f] && tbox.dTextInput && tbox.dTextInput.horizontalAlignment)
                        tbox.dTextInput.horizontalAlignment = fields_alignments[f]

                    if(fields_font && fields_font[f] && tbox.font && tbox.font.family )
                        tbox.font.family = fields_font[f]

                    if(tbox.border && tbox.border.width){
                        tbox.border.width = 0.5
                    }


                    if(ZGlobal.functions.isDef(adv.global_override)){
                        for(var g in adv.global_override){
                            if(ZGlobal.functions.isDef(tbox[g]))
                                tbox[g] = adv.global_override[g]
                        }
                    }

                    if(adv.fields_override  && adv.fields_override[f] ){
                        for(var ff in adv.fields_override[f]){
                            if(tbox.hasOwnProperty(ff))
                                tbox[ff] = adv.fields_override[f][ff]
                        }
                    }




                }

                if(debugMode) {
                    console.log("GEN HEDER FINITO")
                    for(f in privates.fieldMap)
                        console.log(f, privates.fieldMap[f])
                }


//                adjustWidths()
                privates.setAlignment()
                adjustWidths()

                if(externalInitFunc){
                    externalInitFunc(fields, fieldMap, model)
                }

            }
//            else if(ZGlobal.functions.isUndef(model)){
//                ZGlobal.functions.clearChildren(row)
//                console.log(rootObject, "clearChildren", row.children)
//            }
//            adjustWidths()



        }
        function hasAndNotIgnored(obj,prop,fieldName){
            var truthVal = obj.hasOwnProperty(prop)
            if(truthVal && adv.fields_ignoreProperties && adv.fields_ignoreProperties[fieldName]){
                if(ZGlobal._.indexOf(adv.fields_ignoreProperties[fieldName] , prop, false) !== -1)
                    return false        //this property is ignored. dont say we have it!!
                return true
            }
            return truthVal
        }
    }



}

