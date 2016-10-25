import QtQuick 2.5
import QtQuick.Controls 1.4
import "MessageTypes"
import Zabaat.Utility 1.1
import Zabaat.Utility.SubModel 1.1
import Zabaat.Base 1.0

Item {
    id : rootObject
    property var   controller : null
    property real  cellHeight : 0.1
    property color color1     : 'white'
    property color color2     : 'orange'
    property font  font       : Qt.font({ pixelSize : 16 })
    property int   longTime   : 3000

    onControllerChanged : if(controller){
          if(typeof controller.newModelAdded === 'function')    controller.newModelAdded.connect(logic.refreshModelFilters);
          if(typeof controller.updateReceived === 'function')   controller.updateReceived.connect(logic.handleUpdateReceived)
          if(typeof controller.createReceived === 'function')   controller.createReceived.connect(logic.handleCreateReceived)
          if(typeof controller.reqSent === 'function')          controller.reqSent.connect(logic.handleReqSent)
          if(typeof controller.resReceived === 'function')      controller.resReceived.connect(logic.handleResReceived)
          if(typeof controller.resProcessed === 'function')     controller.resProcessed.connect(logic.handleResProcessed)

          logic.refreshModelFilters()
    }

    Component.onDestruction:  if(controller){
          if(typeof controller.newModelAdded === 'function')    controller.newModelAdded.disconnect(logic.refreshModelFilters);
          if(typeof controller.updateReceived === 'function')   controller.updateReceived.disconnect(logic.handleUpdateReceived)
          if(typeof controller.createReceived === 'function')   controller.createReceived.disconnect(logic.handleCreateReceived)
          if(typeof controller.reqSent === 'function')          controller.reqSent.disconnect(logic.handleReqSent)
          if(typeof controller.resReceived === 'function')      controller.resReceived.disconnect(logic.handleResReceived)
          if(typeof controller.resProcessed === 'function')     controller.resProcessed.disconnect(logic.handleResProcessed)
    }





    QtObject {
        id : logic

        property var modelFilters
        property var modelTypes : ["All","req", "res" , "Get","Post","Put","Delete","update","create"]

        function findCbId(id) {
            for(var i = lm.count - 1 ; i >=0; --i){
                var item = lm.get(i)
                if(item.cbId === id)
                    return i;
            }
            return -1;
        }
        function findAllCbId(id){
            var arr = []
            for(var i = 0 ; i < lm.count; ++i){
                var item = lm.get(i)
                if(item.cbId === id)
                    arr.push(i);
            }
            return arr
        }


        property QtObject counts : QtObject {
            property int getReq          : 0
            property int putReq          : 0
            property int postReq         : 0
            property int deleteReq       : 0
            property int req             : 0
            property int res             : 0
            property int updateMessages  : 0
            property int createdMessages : 0
        }
        property QtObject filters: QtObject {
            id: filters
            property var model
            property var type
            property var func


            onModelChanged: zsub.filterFunc = logic.filterFuncGenerator()
            onTypeChanged: zsub.filterFunc = logic.filterFuncGenerator()
            onFuncChanged: zsub.filterFunc = logic.filterFuncGenerator()
        }

        property ListModel lm : ListModel { id : lm; dynamicRoles: true }
        property ZSubModel zsub : ZSubModel{
            id : zsub
            sourceModel : lm
        }


        function handleUpdateReceived(model,id,data) {
//            console.log('updateReceived', model,id)

            //updatedModel, updatedId
            var time = new Date()
            lm.append({ type : "update",
                        _data : data,
                        id   : id,
                        time : time,
                        model : model
                      })
        }
        function handleCreateReceived(model,id,data)  {
//            console.log('createReceived', model,id)

            var time = new Date()
            lm.append({ type  : "create",
                        _data  : data,
                        id    : id,
                        time  : time,
                        model : model
                      })
            //createdModel, createdId
        }
        function handleReqSent(id,type,url,params)  {
//            console.log('req sent', id, type, url, params, Qt.formatTime(new Date()))
            var arr   = Lodash.compact(url.toString().split("/"))
            var model = arr[0]
            var fn    = arr[1]
            var time = new Date()
            var data = params
            var cbId = id

            arr = Lodash.compact(id.toString().split("/"))
            id = arr[arr.length -1]

            lm.append({ type    : "req",
                        _data   : data,
                        id      : id,
                        time    : time,
                        model   : model,
                        func    : fn,
                        reqType : type,
                        cbId    : cbId,
                        procTime : -1,
                        resIdx  : -1,
                      })

            //id,type,url,params
        }
        function handleResReceived(id,type,url,res)  {
            //id,type,url,res
            var arr   = Lodash.compact(url.toString().split("/"))
            var model = arr[0]
            var fn    = arr[1]
            var time = new Date()
            var data = res
            var cbId = id

            var reqIdx =  findCbId(cbId)
//            console.log("reqIdx is " , reqIdx)
            arr = Lodash.compact(id.toString().split("/"))
            id = arr[arr.length -1]

            lm.append({ type    : "res",
                        _data   : data,
                        id      : id,
                        time    : time,
                        model   : model,
                        func    : fn,
                        reqType : type,
                        cbId    : cbId,  //use this to find matching req res
                        procTime : -1,
                        reqIdx  : reqIdx
                      })

            if(reqIdx !== -1) {
                var item    = lm.get(reqIdx)
                item.resIdx = lm.count - 1  //hooray. tget the last item
//                console.log("reqIdx is " , item.resIdx = 1)
            }

//            console.log('res gotten', id, type, url, res, Qt.formatTime(new Date()))
        }
        function handleResProcessed(id, time) {
            var cbId = id
            var indices = findAllCbId(id);
            for(var i = 0; i < indices.length ; ++i) {
                var idx = indices[i]
                lm.get(idx).procTime = time;
            }
        }
        function refreshModelFilters(){
            lv.currentIndex = -1
            modelFilters = null
            modelFilters = Lodash.flatten(['All'].concat(Lodash.clone(controller.getAllModelNames())))
        }


        function filterFuncGenerator() {
            return function(a) {
                var filterPass = filters.model ? a.model === filters.model : true
                var typePass   = filters.type  ? a.type  === filters.type || a.reqType === filters.type  : true
                var funcPass   = filters.func  ? a.func  === filters.func  : true

                return filterPass && typePass && funcPass
            }
        }

    }

    Item {
        id : gui
        anchors.fill: parent

        Item {
            id     : searchAndFilterArea
            width  : parent.width
            height : parent.height * 0.07

            Row {
                width  : parent.width
                height : parent.height
                ComboBox {
                    id : modelFilter
                    width  : parent.width / 4
                    height : parent.height
                    model  : logic.modelFilters
                    onCurrentTextChanged: filters.model = currentText === "All" ? undefined : currentText
                }
                ComboBox {
                    id : typeFilter
                    width  : parent.width / 4
                    height : parent.height
                    model  : logic.modelTypes
                    onCurrentTextChanged: filters.type = currentText === "All" ? undefined : currentText
                }
                Rectangle {
                    id : fnFilter
                    width  : parent.width / 4
                    height : parent.height
                    border.width: 1
                    TextInput {
                        anchors.fill: parent
                        anchors.margins: 5
                        font : rootObject.font
                        onTextChanged : filters.func = text === "" ? undefined : text
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Slider {
                    width  : parent.width / 4
                    height : parent.height
                    minimumValue: 0
                    maximumValue: 10000
                    value : rootObject.longTime
                    onValueChanged : rootObject.longTime= value

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        text : parent.value.toFixed(2) + " ms"
                    }
                }
            }



        }


        SplitView {
            width : parent.width
            height : parent.height - searchAndFilterArea.height
            anchors.bottom: parent.bottom

            Item {
                id : messagesView
                width : parent.width * 0.25
                height : parent.height

                ScrollView {
                    anchors.fill: parent
                    ListView {
                        id : lv
                        model : zsub
                        delegate : Loader {
                            width  : lv.width
                            height : lv.height * cellHeight

                            property var m : lv.model && lv.model.count > index ? lv.model.get(index) : null

                            onLoaded : if(item){
                                if(item.hasOwnProperty('model'))
                                    item.model = Qt.binding(function() { return m })
                                if(item.hasOwnProperty('index'))
                                    item.index = Qt.binding(function() { return index })
                                if(typeof item.clicked === 'function')
                                    item.clicked.connect(function() { lv.currentIndex = index })
                                if(item.hasOwnProperty('sourceModel'))
                                    item.sourceModel = lm

                            }

                            sourceComponent : type ? components["cmp_" + type] : null
                        }
                    }
                }
            }

            Item {
                id : messageDetailsView
                width : parent.width * 0.75
                height : parent.height

                Loader {
                    id : detailLoader
                    anchors.fill: parent
                    property var m : lv.model && lv.count > lv.currentIndex ? lv.model.get(lv.currentIndex) : null
                    property bool detailViewToggle : false

                    onMChanged : {
                        if(item ) {
                            detailViewToggle = item.detailViewToggle ? true : false
                        }
                        sourceComponent = null  //to refresh
                        sourceComponent = m ? components['cmp_' + m.type]  : null
                    }
                    onLoaded : if(item){
                                   item.state = 'detailed'
                                   if(item.hasOwnProperty('model'))
                                       item.model = Qt.binding(function() { return m })
                                   if(item.hasOwnProperty('index'))
                                       item.index = lv.currentIndex
                                   if(typeof item.clicked === 'function')
                                       item.clicked.connect(function() { lv.currentIndex = index })
                                   if(item.hasOwnProperty('sourceModel'))
                                       item.sourceModel = lm
                                   if(item.hasOwnProperty('detailViewToggle'))
                                       item.detailViewToggle = detailViewToggle
//                                   if(item.hasOwnProperty('res')) {

//                                   }
                               }

                }
            }


        }

    }



    Item {
        id : components
        property Component cmp_update : Component{
            id: cmp_update
            Update{
                lvIdx : lv.currentIndex
            }
        }

        property Component cmp_create : Component{
            id: cmp_create
            Update {
                lvIdx : lv.currentIndex
                bgkColor: 'green'
            }
        }

        property Component cmp_req : Component{
            id : cmp_req
            Req {
                lvIdx : lv.currentIndex
                bgkColor: "orange"
                textColor: 'black'
                longTime : rootObject.longTime
            }
        }

        property Component cmp_res : Component{
            id : cmp_res
            Res {
                lvIdx : lv.currentIndex
                bgkColor: 'steelblue'
                longTime : rootObject.longTime
//                title : "RES"
            }
        }


    }






}

