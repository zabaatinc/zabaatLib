import QtQuick 2.4
import Zabaat.UI.Wolf 1.1
import Zabaat.UI.HUD  1.0
import Zabaat.Misc.Global 1.0

/*!
   \brief ZDynamicFormButtons - Dynamically creates ZButtons that open dynamically generated ZDynamicForms based on information provided. The forms created are highly customizable
                                based on the properties provided here (which are passed onto the ZDynamicForm(s).
   \inqmlmodule Zabaat.UI.Wolf 1.0
   \relates ZDynamicForm

   \code

   //using standard ZDynamicForm
   ZDynamicFormButtons
    {
            lvPtr       : employeeSelector
            showLabels  : false

            property var function1 : function(obj,cb) { some code }
            property var function2 : function(startDate, endDate) { some code for specialForm }

            _data : [{ label : "Edit Employee"  , icon : "\uf044", populate : true,  ignoreIdField : false, func: function1                                  },
                    { label : "Add Employee"   , icon : "\uf067", populate : false, ignoreIdField : true,  func: function1                                  },
                    { label : "Generate Report", icon : "\uf073", populate : false, ignoreIdField : true,  func: function2, specialForm: { name : 'DateSelector', importPath : Qt.resolvedUrl("./") } }
                    ]
            exclusionArr:   ["updatedAt","createdAt","lastEntry"]//,"clockState"]
            typeArr : {firstName : {type : 'ZTextBox'},     lastName : {type: 'ZTextBox', valueField: 'text', labelField : 'labelName', override { width : 200 }   }
            ordering : ["firstName", "lastName" ]
    }

    //using a custom defined form instead. Look at the specialForm field. DateSelector is the name of the .qml we wish to use instead of our standard ZDynamicForm, and we have to provide
    //an import path for it relative to wherever we are using ZDynamicFormButtons from.
    ZDynamicFormButtons
    {
        _data : [{ label : "Generate Report", icon : "\uf073", populate : false, ignoreIdField : true,  func: genReportFunc, specialForm: { name : 'DateSelector', importPath : Qt.resolvedUrl("./") } } ]
    }


    \endcode
*/

//TODO, add the ability to pass a custom parent to put the new dynamic form in!! Highly requested FEATURE :P
Item
{
    id : rootObject
    width : 300
    height : 32

    property alias spacing : btnList.spacing
    property int padding   : 100

    /*! if no lvPtr is provided, we will look in here to populate for edits! */
    property var selectedItem : null

    /*! the orientation of the button list */
    property alias orientation : btnList.orientation

    /*! The pointer of the listView the ZDynamicFormButtons is looking at. If none is provided, this class will automatically look at its parent and if it's a listview, will set lvPtr to point to it */
    property var lvPtr : null
    Component.onCompleted: if(!lvPtr && parent && parent.toString().indexOf('QQuickListView') !== -1)   lvPtr = parent


    /*! Allows for custom handling of how certain fields look. This is useful if you don't want to use the typeArr property for these fields and want them to just appear in ZTextBox instead
        \code
        //The field value is passed in as obj to the functions defined on the respective functions defined on the field names (clockIn, clockOut in this case)
        displayFunctions:  { clockIn : function(obj) { return Qt.formatTime(obj, "hh:mm AP") } ,
                            clockOut : function(obj) { return Qt.formatTime(obj, "hh:mm AP") } }
        \endcode
    */
    property var displayFunctions : []

    /*! Determines the order in which the fields will appear on the ZDynamicForm(s). If some fields are left out, there no guarantees in which order they will appear.
       \code
        //In this example, the ZDynamicForm guarantees that it will draw firstName and then lastName first. All the rest of the fields may be drawn at random.
        ordering : ["firstName", "lastName"]
       \endcode
    */
    property var ordering : []

    /*!
        Allows us to override the default ZTextBox type of the dynamic form for any field! Defaults to empty array.
        \code
        //The type object contains the following
        //<type>  is the QML type (found in Zabaat.UI.Wolf) . Should not contain .qml at the end. valid examples are ZTextBox, ZTimePicker, etc etc
        //<valueField> is the property where value should be shoved in (and read from!)
        //<labelField> is the name where labels should be shoved in (field names such as firstName, etc)
        //<override> lets us inject stuff into this component on the form and not populate it from the model! Essentially allows access to the object's qml properties such as width, height, color, etc.
        //<import>   lets us define import path to dir or plugin for this component!

        typeArr : ({
                    firstName : { type : 'ZButton' , valueField : 'text', labelField : 'labelName' }
                    lastName  : { type : null }     //makes this field invisible in the form
                    favFoods  : { import: [Qt.resolvedUrl('../path/to/my/plugin/'), Zabaat.Misc.Derp 1.0], type : 'ZComboBoxQt', override { derp : 'herp', slurp : 'jurp' } }
                  )}
        \endcode
    */
    property var typeArr : []

    /*!
       Should be null or should point to a a function that accepts a JSObject as Input. This function
       should accept a JsObject input. The object will be created by ZDynamicForm when the user hits
       'apply' or 'ok' and then passed to this function. The job of this function is to verify all data
       is valid. The function should return null in happy state!

       \code
       validationFunc : function (obj)
       {
           if(obj.clockIn > obj.clockOut)
               return "ClockIn cannot be greater than ClockOut Time"
           return null
       }
       \endcode
    */
    property var validationFunc   : null
    property color color : ZGlobal.style.accent


    /*!
    Allows us to exclude fields in the ZDynamicForm that will be generated
        \code
         exclusionArr: ["updatedAt","createdAt","lastEntry"]
        \endcode
    */
    property var exclusionArr     : []

    /*! If enabled shows label property provided in _data as text on the dynamically created ZButtons */
    property bool showLabels : false

    /*! Width of each dynamic button (which opens up a ZDynamicForm) */
    property int btnWidth  : orientation === Qt.Vertical ? width   : btnList.count > 0 ? (width - btnList.spacing * btnList.count)  /  btnList.count  : 32

    /*! Height of each dynamic button (which opens up a ZDynamicForm) */
    property int btnHeight : orientation === Qt.Horizontal ? height : btnList.count > 0 ? (height - btnList.spacing * btnList.count) /  (btnList.count): 32

    /*! points to the dynamically created window with the ZDynamicForm in it. */
//    property var winPtr : null

    /*! width of the ZDynamicForm(s) to be made*/
    property int windowWidth : 550

    /*! height of the ZDynamicForm(s) to be made*/
    property int windowHeight : 500

    /*!
    Responsible for how many buttons (and hence, how many ZDynamicForms) there will be.  Defines their attributes! A valid object in this array has these fields:
        \code
        //@param label          string    - This is the display name/title of the ZButton / ZDynamicForm
        //@param icon           string    - This should be the unicode string for a fontAwesomeIcon (to be shown on the ZButton)
        //@param populate       bool      - Determines whether we should prepoulate the ZDynamicForm with data at the currentIndex of the list. Use this for Edit forms and leave this off for Add forms.
        //@param ignoreIdField  bool      - Determines whether we exclude the Id field from the ZDynamicForm.
        //@param specialForm    JsObject  - If this field is defined , it lets us use another QML instead of the standard ZDynamicForm
        //                                  when making a form window. Make sure that these properties, cause they will be passed in to it:
        //                                                offsetX            int             -optional. Used to align our dropdowns
        //                                                offsetY            int             -optional. Used to align our dropdowns
        //                                                title              string          -This is 'label' field which needs to be in each _data object
        //                                                _displayFunctions  JsObject        -This is the same as displayFunctions as in the root of this QML. It will be passed in to the form
        //                                                validationFunc     function        -This is the same as validationFunc as in the root of this QMl. It will be passed in to the form
        //                                                func               function        -This is the same as a _data object's func. See below. Will be passed in
        //                                                init()             function        -This is supposed to be local to the form provided . It's purpose is to initialize the form
        //                                                callBackFunc       function        -This is the function that will be run when func is run!
        //                                                typeArr            function        -optional. Used to determine what each field's QML type is (ZTextbox, ZComboBoxQt , etc)
        //
        //@param noForm         bool    -optional, if not provided, considered to be false. This option will just run the respective function and not make a ZDynamicForm. Use this for simple functions that
        //                                         do not need any data entry (no need for form).
        //
        ///@param func           function  - The function to run when the user hits the 'ok' button or the 'apply' button on the ZDynamicForm
        //                                  Should be a ptr to a function. Should take 2 params:
        //                                                obj JsObject   - The culminated object from the form will be passed in here
        //                                                cb  function   - The callback function to run once server reply is received! It needs to accept one argument:
        //                                                string msg     - The response from the server
        //
        //
        //example:
        //    _data : [{ label : "Edit Employee"  , icon : "\uf044", populate : true,  ignoreIdField : false, func: function1                                  },
        //             { label : "Add Employee"   , icon : "\uf067", populate : false, ignoreIdField : true,  func: function1                                  },
        //             { label : "Generate Report", icon : "\uf073", populate : false, ignoreIdField : true,  func: function2, specialForm: { name : 'DateSelector', importPath : Qt.resolvedUrl("./") } }
        //            ]
        \endcode
    */
    property var _data : null
    on_DataChanged: {
        if(_data)
        {
            //clear map
            btnList.map = {}
            lm.clear()
            lm.append(_data)
        }
    }

    function runFunction(index){
        var btn = Number(index) ? btnList.getDelegateInstanceAt(index) : btnList.map[index]
        if(btn)
            btn.myFunc()
    }



    ListView  {
        id : btnList

        width  : parent.width
        height : parent.height

        orientation  : Qt.Horizontal
        spacing : 20
        property var map : ({})

        model : ListModel{
            id : lm
            dynamicRoles: true
        }

        delegate: ZButton {
            id : btn

            property bool imADelegate : true
            property int _index : index
            property string _icon :  btnList.model && btnList.model.get(index) && btnList.model.get(index).icon ? btnList.model.get(index).icon : ""

            //add this to map if it was given a key. TEE HEE!!
            Component.onCompleted : {
                if(_data[index].key)
                    btnList.map[_data[index].key] = this
            }

            icon            : _icon
            text            : typeof showLabel !== 'undefined' && showLabel  ? label : rootObject.showLabels ? label : ""
            width           : rootObject.btnWidth
            height          : rootObject.btnHeight
            visible         : !ZGlobal.functions.isUndef(_data[index]) && !ZGlobal.functions.isUndef(_data[index].func)
            defaultColor    : rootObject.color

            function myFunc() {
                if(typeof noForm === 'undefined' || !noForm)
                    rootObject.makeWindow(rootObject._data[index].func, label, rootObject._data[index].populate, ignoreIdField, _data[index].callBack,  _data[index].specialForm, _data[index].grid, _data[index].vFunc, _data[index].advancedGrid, _data[index].applyBtn, _data[index].okBtn ,  _data[index].allowEsc, _data[index].tracking, _data[index].selectedItem)
                else
                    rootObject._data[index].func(_data[index].callBack)
            }

            onBtnClicked : myFunc()
        }
        function getDelegateInstanceAt(index){
            for(var i = 0; i < btnList.contentItem.children.length ; i++)
            {
                var child = btnList.contentItem.children[i]
                if(child.imADelegate && child._index === index)
                    return child
            }
            return null
        }

    }

    Item      { id : modelContainer     }
    Item      {
        id : windowContainer
        property color focusColor_win   : Qt.rgba(ZGlobal.style.accent.r, ZGlobal.style.accent.g, ZGlobal.style.accent.b)
        property color unfocusColor_win : Qt.lighter(focusColor_win,50)
    }

    //TODO, change the state of this thing. This is getting pretty retarded.
    function makeWindow(func, title, populate, ignoreIdField, callBackFunction, specialForm, grid, vFuncFromData, advancedGrid, apply, ok, allowEsc, tracking, selectedItem)
    {
        if(title === null)            title = ""
        if(populate === null)         populate = false
        if(ignoreIdField === null)    ignoreIdField = true

        var formName = 'ZDynamicForm'
        var imports = ["QtQuick.Window 2.2", "QtQuick 2.0","Zabaat.UI.Wolf 1.1"]
        if(typeof specialForm === 'object') {
            formName = specialForm.name
            var impPath = specialForm.importPath
            if(impPath.charAt(0) !== "'")
            {
                impPath = impPath.split(' ')
                impPath = impPath[0].indexOf('.') === -1 ? ZGlobal.functions.spch(specialForm.importPath) : specialForm.importPath
                //The condition in the ternary means that no dots were found!! That means this is a directory path not a plugin path!
            }

            if(ZGlobal._.indexOf(imports, impPath,false) === -1)        //only add things we don't already have in here!
                imports.push(impPath)
        }
        else if(typeof specialForm === 'string')
            formName = specialForm


        var win = ZGlobal.functions.getQmlObject(imports, "Window\n
                                                          {\n
                                                              id : rootObject;
                                                              visible : true;\n
                                                              property alias titleBar : ztitle;\n
                                                              property alias colorRect : clrRect;\n

                                                              property int winIndex    : -1;
                                                              signal imClosing(var self);
                                                              onClosing : imClosing(rootObject);

                                                              //property point size : Qt.point(width, height)
                                                              //onSizeChanged : console.log(size.x, size.y)

                                                              color : 'transparent';
                                                              Rectangle { id: clrRect; anchors.fill: parent;  }
                                                              property alias form: zform;\n" +
                                                              formName +
                                                              "{\n
                                                                 id : zform ; width : parent.width; height: parent.height - ztitle.height;      y: ztitle.height;
                                                              }\n

                                                              ZTitleBar{
                                                                id : ztitle ; width : parent.width; height: 30; haveMinimize: false; haveMaximize : false;
                                                              }

                                                               Rectangle { anchors.fill: parent; color : 'transparent'; border.width: 3}
                                                            }", Qt.application)

        if(ZGlobal.objects.registerNewWindow)
            ZGlobal.objects.registerNewWindow(win)

        win.flags           = Qt.FramelessWindowHint | Qt.Window
        win.title           = title
        win.titleBar.title  = title
        win.titleBar.winPtr = win
        win.width           = grid && grid.width ?  grid.width   : windowWidth
        win.height          = grid && grid.height ? grid.height  : windowHeight
        win.titleBar.focusColor      = windowContainer.focusColor_win
        win.titleBar.unfocusColor    = windowContainer.unfocusColor_win
        win.imClosing.connect(function(win) { if(win) win.destroy()  } )

        //TODO, perhaps make this ni ZGlobal.styles so we don't have to shove it into objects!!
        //console.log(rootObject, "found ZGlobal.objects.baseColor", ZGlobal.objects.baseColor.color, ZGlobal.objects.baseColor.opacity)
        win.colorRect.color   = ZGlobal.style._default
        win.colorRect.opacity = ZGlobal.settings.backgroundOpacity

        //Grid related
        if(grid !== null && typeof grid !== 'undefined' && win.form.grid != null && typeof win.form.grid !== 'undefined') {
            if(grid.columnSpacing && win.form.grid.columnSpacing) win.form.grid.columnSpacing = grid.columnSpacing
            if(grid.columns       && win.form.grid.columns)       win.form.grid.columns       = grid.columns
            if(grid.flow          && win.form.grid.flow)          win.form.grid.flow          = grid.flow
            if(grid.rowSpacing    && win.form.grid.rowSpacing)    win.form.grid.rowSpacing    = grid.rowSpacing
            if(grid.rows          && win.form.grid.rows)          win.form.grid.rows          = grid.rows
        }

        if(win.form.hasOwnProperty('validationFunc')){
            if(vFuncFromData !== null && typeof vFuncFromData !== 'undefined')          win.form.validationFunc    = vFuncFromData
            else                                                                        win.form.validationFunc    = validationFunc
        }
        if(typeof allowEsc === 'undefined' || allowEsc) {
            var action3 = ZGlobal.functions.getQmlObject(["QtQuick 2.4", "QtQuick.Controls 1.2"], "Action{}", win)
            action3.shortcut = "Escape"
            action3.triggered.connect(win.close)
        }

        if(win.form.hasOwnProperty('_data'))                                            win.form._data = selectedItem ? selectedItem : getLvData(populate, ignoreIdField)
        if(win.form.hasOwnProperty('ordering'))                                         win.form.ordering = ordering
        if(win.form.hasOwnProperty('isActive'))                                         win.form.isActive = Qt.binding(function(){ return win.activeFocusItem !== null } )
        if(win.form.hasOwnProperty('trackChanges') && typeof tracking !== 'undefined')  win.form.trackChanges = tracking
        if(win.form.hasOwnProperty('padding'))                                          win.form.padding = padding
        if(typeof apply !== 'undefined' && win.form.hasOwnProperty('applyBtn'))         win.form.applyBtn = apply
        if(typeof ok !== 'undefined' && win.form.hasOwnProperty('okBtn'))               win.form.okBtn = ok
        if(win.form.hasOwnProperty('offsetX'))                                          win.form.offsetX = Qt.binding(function() { return win.x } )
        if(win.form.hasOwnProperty('offsetY'))                                          win.form.offsetY = Qt.binding(function() { return win.y } )
        if(win.form.hasOwnProperty('title'))                                            win.form.title  = title
        if(win.form.hasOwnProperty('_displayFunctions'))                                win.form._displayFunctions = displayFunctions
        if(win.form.hasOwnProperty('advancedGrid') && advancedGrid)                     win.form.advancedGrid = advancedGrid
        if(win.form.hasOwnProperty('callBackFunc'))                                     win.form.callBackFunc = callBackFunction
        if(win.form.hasOwnProperty('func'))                                             win.form.func         = func
        if(win.form.hasOwnProperty('typeArr'))                                          win.form.typeArr      = typeArr
        if(typeof win.form.hasOwnProperty('closeWindow'))                               win.form.closeWindow.connect(win.close)
        if(win.form.hasOwnProperty('init') && typeof win.form.init === 'function')      win.form.init()


        win.x = ZGlobal.app.width/2  - win.width/2
        win.y = ZGlobal.app.height/2 - win.height/2

//        winPtr = win
    }


    /*! returns data at the current index of the listView or if selectedItem is provided and not lvPtr, it will use the data from that instead*/
    function getLvData(populate, ignoreIdField) {
        var data = []
        var item = null
        if(lvPtr != null && typeof lvPtr !== 'undefined' &&  lvPtr.count > 0)           item = lvPtr.model.get(lvPtr.currentIndex)
        else if(selectedItem != null)                                                   item = selectedItem

        if(item)
        {
            for(var k in item)
            {
               if((k === "id" && ignoreIdField)  ||  isExcluded(k)               ||  k === 'objectName' ||
                    k === 'objectNameChanged'    ||  k.indexOf("__") != -1       ||  typeof item[k] == 'object')
                    continue    //go one iteration forward

                if(populate && typeof item[k] !== 'undefined')               data.push({field : k, value : item[k] })
                else                                                         data.push({field : k, value : ""})
            }
        }

        return data
    }
    function isExcluded(key) {
        for(var k in exclusionArr)
        {
            if(exclusionArr[k] === key)
                return true
        }
        return false
    }










}
