import QtQuick 2.5
import QtQuick.Controls 1.4
import "Components"
//Shows messages and data inside a restful array
Item {
    id : rootObject
    property var ptr_RESTFULArray;
    onPtr_RESTFULArrayChanged: ptrChangeTimer.start()



    QtObject {
        id : logic
        function firstToUppercase(a) {
            return a.charAt(0).toUpperCase() + a.slice(1);
        }

        //returns a timer object.  Call obj.end() to get the time since when it was created.
        function timer() {
            function now(){
                return +(new Date().getTime())
            }
            var timeobj = { start : now() }
            timeobj.end = function() {
                return now() - timeobj.start;
            }
            return timeobj;
        }

        property QtObject originalFunctions : QtObject {
            id : originalFunctions
            property var ra
            property var reset
            property var runUpdate
            property var set
            property var get
            property var del

            function injectLoggingFunctions(){
                //replace factory functions
                ra.reset = function() {
                    var timer = logic.timer();
                    originalFunctions.reset();
                    tab_log_model.append({time : timer.end(), type : "reset"})
                }
                ra.runUpdate = function(data) {
                    var timer = logic.timer();
                    originalFunctions.runUpdate.apply(this,arguments);
                    tab_log_model.append({time : timer.end(), type : "runUpdate", data : data })
                }
                ra.set = function(path, data) {
                    var timer = logic.timer();
                    var res = originalFunctions.set.apply(this,arguments);
                    tab_log_model.append({time : timer.end(), type : "set", data : data, path : path, res : res })
                }
                ra.get = function(path) {
                    var timer = logic.timer();
                    var res  = originalFunctions.get.apply(this,arguments);
                    tab_log_model.append({time : timer.end(), type : "get", path : path, res : res })
                }
                ra.del = function(path) {
                    var timer = logic.timer();
                    var res  = originalFunctions.del.apply(this,arguments);
                    tab_log_model.append({time : timer.end(), type : "del", path : path, res : res })
                }
            }

            function storeOriginalFunctions() {
               if(ra) {
                   reset        =  ra.reset     ;
                   runUpdate    =  ra.runUpdate ;
                   set          =  ra.set       ;
                   get          =  ra.get       ;
                   del          =  ra.del       ;

                   console.log('reset',typeof reset);
                   console.log('runUpdate',typeof runUpdate);
                   console.log('set',typeof set);
                   console.log('get',typeof get);
                   console.log('del',typeof del);
               }
            }

            function restoreOriginalFunctions() {
                if(ra){
                    if(typeof reset     === 'function') ra.reset     = reset;
                    if(typeof runUpdate === 'function') ra.runUpdate = runUpdate;
                    if(typeof set       === 'function') ra.set       = set;
                    if(typeof get       === 'function') ra.get       = get;
                    if(typeof del       === 'function') ra.del       = del;
                }
            }

            Component.onDestruction: restoreOriginalFunctions()
        }


    }
    QtObject {
        id : guiLogic
        property int selectedTab : 0
    }

    Item {
        id : gui
        anchors.fill: parent

        Row {
            id : tabSelectorRow
            width : childrenRect.width
            height : parent.height * 0.1

            SimpleButton {
                id : tabSelectorRow_btn_data
                width : rootObject.width * 0.1
                height : parent.height
                text : "data"
                onClicked : guiLogic.selectedTab = 0
                color : guiLogic.selectedTab === 0 ? "orange" : 'white'
            }
            SimpleButton {
                id : tabSelectorRow_btn_signals
                width : rootObject.width * 0.1
                height : parent.height
                text : "signals"
                onClicked : guiLogic.selectedTab = 1
                color : guiLogic.selectedTab === 1 ? "orange" : 'white'
            }
            SimpleButton {
                id : tabSelectorRow_btn_log
                width : rootObject.width * 0.1
                height : parent.height
                text : "log"
                onClicked : guiLogic.selectedTab = 2
                color : guiLogic.selectedTab === 2 ? "orange" : 'white'
            }
        }


        Item {
            id : tabs
            width : parent.width
            height : parent.height - tabSelectorRow.height
            anchors.bottom: parent.bottom
            Item {
                id : tab_data
                anchors.fill: parent
                visible : guiLogic.selectedTab === 0
            }
            SplitView {
                id : tab_signals
                anchors.fill: parent
                visible : guiLogic.selectedTab === 1

                Connections {
                    target    : ptr_RESTFULArray ? ptr_RESTFULArray : null
                    onUpdated : tab_signals_model.append({type:'update',path:path,data:data, oldData:oldData,at:new Date()})
                    onCreated : tab_signals_model.append({type:'create',path:path,data:data,at:new Date()})
                    onDeleted : tab_signals_model.append({type:'delete',path:path,at:new Date()})
                }

                ListView {
                    id : tab_signals_listview
                    width : parent.width * 0.3
                    height : parent.height
                    model : ListModel { id: tab_signals_model ; dynamicRoles : true }
                    delegate : SignalTiny {
                        width : ListView.view.width
                        height : ListView.view.height * 0.1
                        m : tab_signals_model.get(index)
                        onClicked: ListView.view.currentIndex = index;
                        showCursor: ListView.view.currentIndex === index
                    }
                }
                SignalDetailed {
                    id : tab_signals_detailedlook
                    width : parent.width * 0.7
                    height : parent.height
                    m : tab_signals_listview.currentItem ? tab_signals_listview.currentItem.m : null
                }



            }
            SplitView {
                id : tab_log
                anchors.fill: parent
                visible : guiLogic.selectedTab === 2

                ListView {
                    id : tab_log_listview
                    width : parent.width * 0.3
                    height : parent.height
                    model : ListModel { id: tab_log_model ; dynamicRoles : true }
                    delegate : LogTiny {
                        width : ListView.view.width
                        height : ListView.view.height * 0.1
                        m : model
                        onClicked: ListView.view.currentIndex = index;
                        showCursor: ListView.view.currentIndex === index
                    }
                }

                LogDetailed {
                    id : tab_log_detailedlook
                    width : parent.width * 0.7
                    height : parent.height
                    m : tab_log_listview.currentItem ? tab_log_listview.currentItem.m : null
                }


            }

        }


    }






    //lets us wait untilt he RESTFULArray is property instantiated. It deterministic.
    //Not a gimmick timer. It will keep triggering until all the functions are finished creating on
    //the RESTFULArray. Then it will do the onChange ops!
    Timer {
        id : ptrChangeTimer
        interval : 10
        running : false
        repeat : true
        onTriggered: {
            if(!rootObject || !rootObject.ptr_RESTFULArray)
                stop();

            var a = typeof rootObject.ptr_RESTFULArray.reset     === 'function'
            var b = typeof rootObject.ptr_RESTFULArray.runUpdate === 'function'
            var c = typeof rootObject.ptr_RESTFULArray.set       === 'function'
            var d = typeof rootObject.ptr_RESTFULArray.get       === 'function'
            var e = typeof rootObject.ptr_RESTFULArray.del       === 'function'

            if(a && b && c && d && e){
                originalFunctions.restoreOriginalFunctions()    //this will restore originalFunctions to the prev ptr_RESTFULArray (if it exists).

                originalFunctions.ra = rootObject.ptr_RESTFULArray;        //now this becomes our ra.
                originalFunctions.storeOriginalFunctions();     //STORE THE ORIGINAL FUNCTIONS SO WE CAN RESTORE THEM LATER!
                originalFunctions.injectLoggingFunctions();     //inject logging functions in the middle
                stop();
            }
        }
    }

}
